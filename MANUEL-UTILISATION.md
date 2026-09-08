# Manuel d’utilisation — Close SPIN-LOT (SC-INV700)

**Application :** FSM Planning (APEX App 1400)  
**Page :** 51 — Close SPIN-LOT  
**Écran legacy :** Speedware SC-INV700

---

## Public concerné

| Profil | Usage |
|--------|--------|
| **Métier / production** | Chercher un main spin lot, vérifier l’impact, fermer le lot |
| **Support** | Diagnostiquer recherche / load / close, messages d’erreur |
| **Développeur APEX** | Collage CSS/JS/Ajax, package `SCT_PRD.close_spin_lot_inv700` |

---

## Vue d’ensemble de l’écran

1. **Find lot** — champ de recherche + filtres **Open** / **All** + bouton **Load lot**
2. **Liste** (gauche) — lots trouvés (max 50), statut SC ou OK
3. **Détail** (droite) — lot principal, quantités, impact de fermeture
4. **Barre d’action** (bas) — Clear selection / Close SPIN-LOT  
5. Tampon **CLOSED!!** si le lot est déjà fermé (OK / DD)

À l’ouverture, la page charge automatiquement les lots **Open** (jusqu’à 50).

---

## Pas à pas utilisateur

### 1. Ouvrir la page

Menu FSM Planning → **Close SPIN-LOT** (Page 51), ou URL alias `CLOSE-SPIN-LOT`.

### 2. Filtrer Open / All

| Filtre | Affiche |
|--------|---------|
| **Open** | Lots non fermés (status pas OK / DD) |
| **All** | Inclut aussi les lots déjà fermés |

### 3. Rechercher

Saisir LOT#, works order, product, yarn flag ou MCODE (ex. `2608`, `2608-0027`, `1F`).

- **Entrée** ou **Load lot** → rafraîchit la liste (sans recharger toute la page).
- 1 seul résultat → détail chargé automatiquement.
- Plusieurs résultats → cliquer une ligne à gauche.

### 4. Vérifier le détail

Contrôler produit, yarn, MCODE, quantités, et la section **Closing impact** (spin lot, WIP, blend, shipment, related lots selon les données).

### 5. Fermer le lot

1. Bouton **Close SPIN-LOT**
2. Confirmer **OK** dans la popup
3. Attendre le toast **SPIN-LOT closed successfully**
4. Tampon **CLOSED!!** + bouton **Already closed**

> La fermeture est **définitive** (COMMIT). En PROD, n’utiliser que des lots autorisés par le métier.

### 6. Effacer la sélection

**Clear selection** vide le détail et la barre d’action (la liste reste).

---

## Tableau des fonctionnalités

| Fonction | En quoi ça aide |
|----------|-----------------|
| Liste Open au démarrage | Voir tout de suite les candidats à fermer |
| Recherche multi-champs | Retrouver un lot sans connaître uniquement le numéro |
| Filtre Open / All | Séparer actifs et déjà archivés |
| Preview détail + impact | Voir ce qui sera mis à OK avant de confirmer |
| Confirmation + Close | Remplace le champ Y/N Speedware par un flux APEX sûr |
| Tampon CLOSED!! | Signal visuel Speedware-like après clôture |
| Limite 50 lots | Garde la page rapide (plafond, pas le total base) |

---

## Dépannage / FAQ

| Symptôme | Cause probable | Action |
|----------|----------------|--------|
| Toujours 50 lots après Entrée | Submit formulaire APEX | Vérifier JS à jour (`preventDefault` sur Enter) |
| `sqlerrm` / JSON invalide au clic | Erreur PL/SQL `LOAD_LOT` | Network → Response ; vérifier tables / synonymes |
| Close → INVALID DATE | Fenêtre `M_PARAM` clé `DATE` | Mettre à jour la plage YYYYMMDD…YYYYMMDD |
| Close → procédure introuvable | Package non déployé | Compiler `close_spin_lot_inv700` dans `FSM.SCT_PRD` |
| Liste vide | Aucun match / droits | Essayer **All** ou un autre terme ; vérifier grants WOOL |
| Deux messages (confirm + succès) | Popup confirm restée ouverte | JS avec `inv700DismissDialogs` |

---

## Glossaire

| Terme | Sens |
|-------|------|
| **Main spin lot** | Lot où `works_order = lot_no` |
| **SC** | Statut ouvert (à fermer) |
| **OK / DD** | Lot fermé / archived |
| **Closing impact** | Tables mises à jour (PROD_LOT, WIP_HDR, D_BLENDHDR, ORD_SHIP, lots liés) |
| **SC-INV700** | Écran Speedware d’origine |

---

## Support APEX / Ajax (court)

| Callback | Entrée | Sortie |
|----------|--------|--------|
| `SEARCH_LOTS` | `x01` = recherche, `x02` = OPEN\|ALL | JSON `{ lots: [...] }` |
| `LOAD_LOT` | `x01` = works order | JSON `{ lot, impact }` |
| `CLOSE_LOT` | `x01` = lot_id | JSON `{ success, message }` |

Logique métier close : `FSM.SCT_PRD.close_spin_lot_inv700(p_lot_id)`  
(chargement : `load_main_spin_lot` + lecture `prod_lot` selon le callback).

Fichiers source : `apex/page51.js`, `apex/page51_ajax.sql`, `sct_prd_close_spin_lot_inv700.sql`.
