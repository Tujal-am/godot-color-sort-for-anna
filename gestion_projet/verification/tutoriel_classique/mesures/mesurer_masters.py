"""Audit des étalons fournis, normalisation interne du master seulement, sans modification du fichier maître.
Usage: python mesurer_references.py --kit /chemin/kit --output mesures.json
Dépendances: Pillow, numpy. Les captures auditées restent celles du commit fd171cf.
"""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image


def bbox(mask, origin=(0, 0)):
    y, x = np.where(mask)
    if not x.size:
        return None
    return [int(x.min()) + origin[0], int(y.min()) + origin[1],
            int(x.max()) + 1 + origin[0], int(y.max()) + 1 + origin[1]]


def ink(image, roi, colour, distance):
    x0, y0, x1, y1 = roi
    crop = image[y0:y1, x0:x1].astype(float)
    return bbox(np.linalg.norm(crop - colour, axis=2) < distance, (x0, y0))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--kit', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    refs = args.output.parent / '_masters_normalises_internes'
    refs.mkdir(exist_ok=True)
    for master in (args.kit / '01_REFERENCES_VALIDEES').glob('*_HD.png'):
        Image.open(master).convert('RGB').resize((480,720),Image.Resampling.LANCZOS).save(refs / master.name.replace('_HD.png','_480x720.png'))
    captures = Path(__file__).resolve().parent.parent / 'captures'
    result = {'unite': 'px sur étalon 480×720', 'convention': 'bbox semi-ouverte [x0,y0,x1,y1)',
              'captures_auditees_commit': 'fd171cf29c773b9d4dcc0a1f7b8fca8294deee1e',
              'reference_seule_normalisee': True, 'references': {}, 'calque_final': {}}
    manifest = json.loads((args.kit / 'manifest.json').read_text())
    result['sha256_manifest'] = {
        item['path']: hashlib.sha256((args.kit / item['path']).read_bytes()).hexdigest() == item['sha256']
        for item in manifest['items']}
    settings = [
        ('01_JOUER', 'JOUER', (180, 210), (301, 325), 195, 314),
        ('02_RECOMMENCER', 'RECOMMENCER', (145, 175), (250, 275), 160, 260),
        ('03_PASSER', 'PASSER', (145, 168), (278, 299), 154, 287),
    ]
    for prefix, screen, top, bottom, actual_top, actual_bottom in settings:
        image = np.array(Image.open(refs / (prefix + '_480x720.png')).convert('RGB'))
        assert image.shape == (720, 480, 3)
        # Recherche du trait horizontal dans la zone annoncée, médiane pour exclure les glyphes.
        y0 = top[0] + int(np.argmin(np.median(image[top[0]:top[1], 150:330, 1], axis=1)))
        y1 = bottom[0] + int(np.argmin(np.median(image[bottom[0]:bottom[1], 150:330, 1], axis=1)))
        def edge_x(lo, hi):
            return lo + int(np.argmin(np.median(image[y0 + 30:y1 - 20, lo:hi, 1], axis=0)))
        actual = np.array(Image.open(captures / (screen + '.png')).convert('RGB'))
        ref_title = ink(image, (145, 170, 430, 250), (20, 107, 151), 12)
        ref_body = ink(image, (145, 210, 435, 295), (21, 70, 117), 12)
        actual_title = ink(actual, (140, actual_top, 430, min(actual_bottom, actual_top + 90)), (8, 110, 153), 4)
        actual_body = ink(actual, (145, actual_top + 45, 430, min(actual_bottom, actual_top + 130)), (8, 64, 117), 4)
        master = Image.open(args.kit / '01_REFERENCES_VALIDEES' / (prefix + '_HD.png'))
        result['references'][screen] = {
            'master_dimensions': list(master.size), 'facteur_master_vers_mobile': 0.5,
            'geometrie_etalon': str((Path('01_REFERENCES_VALIDEES') / (prefix + '_HD.png'))),
            'bords_forts_encart_inclusifs': [edge_x(26, 38), y0, edge_x(441, 455), y1],
            'incertitude_bords_px': 1,
            'titre_encre_reference': ref_title, 'titre_encre_godot_audite': actual_title,
            'titre_ecart_max_bord_px': max(abs(a-b) for a,b in zip(ref_title, actual_title)),
            'corps_encre_reference': ref_body, 'corps_encre_godot_audite': actual_body,
            'methode_encre': 'master normalisé Lanczos, distance RGB dans ROI déclarée ; incertitude ±1–2 px ; ce ne sont pas des boîtes Label',
        }
    rgba = np.array(Image.open(args.kit / '02_RESSOURCES_NATIVES/Calque_A_Toi_De_Jouer_RGBA_1024x1536.png'))
    for name, colour in [('fond', (253, 244, 228, 128)), ('titre', (15, 58, 104, 255)),
                         ('texte', (9, 63, 112, 255)), ('bordure', (227, 133, 79, 215)),
                         ('case_contour', (32, 86, 135, 240))]:
        mask = np.all(rgba == colour, axis=2)
        box = bbox(mask)
        result['calque_final'][name] = {'rgba_exact': list(colour), 'pixels_exacts': int(mask.sum()),
                                       'bbox_hd_couleur': box,
                                       'bbox_mobile_couleur': [v * .46875 for v in box]}
    support = bbox(rgba[:, :, 3] > 0)
    result['calque_final']['support_alpha_mobile'] = [v * .46875 for v in support]
    result['calque_final']['alpha_fond'] = 128 / 255
    result['calque_final']['alpha_fond_godot_audite'] = .70
    result['calque_final']['limite'] = 'Le calque prouve ces RGBA, pas une décomposition unique des masters RGB.'
    result['references']['FINAL'] = {'master_dimensions': [1024, 1536],
        'facteur_master_vers_mobile': .46875, 'geometrie_etalon': '01_REFERENCES_VALIDEES/04_A_TOI_DE_JOUER_HD.png',
        'titre_encre_reference_mobile': [113, 233, 382, 272],
        'titre_encre_godot_audite': ink(np.array(Image.open(captures / 'A_TOI_DE_JOUER.png').convert('RGB')),
                                       (80, 220, 405, 280), (8, 64, 117), 4)}
    args.output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print('14 SHA256 conformes:', all(result['sha256_manifest'].values()))
    print('Mesures écrites:', args.output)


if __name__ == '__main__':
    main()
