#!/bin/bash
# Auto-pilot: lance une session Claude Code par story, en boucle
# Usage: ./run-stories.sh
# Pour arreter: Ctrl+C

PROMPT='Lis le fichier _bmad-output/implementation-artifacts/AGENT-PROMPT.md et execute les instructions. Travaille de maniere 100% autonome sans poser aucune question. L utilisateur n est pas disponible.'

MAX_STORIES=35
COMPLETED=0

echo "=== AUTO-PILOT: Lancement des stories ==="
echo "Ctrl+C pour arreter a tout moment"
echo ""

while [ $COMPLETED -lt $MAX_STORIES ]; do
    COMPLETED=$((COMPLETED + 1))
    echo ""
    echo "============================================"
    echo "  Session $COMPLETED / $MAX_STORIES"
    echo "  $(date '+%Y-%m-%d %H:%M:%S')"
    echo "============================================"
    echo ""

    # Lance claude en mode non-interactif avec tous les droits
    claude -p "$PROMPT" \
        --allowedTools "Bash,Edit,Read,Write,Glob,Grep,WebFetch,WebSearch,Task" \
        --verbose

    EXIT_CODE=$?

    echo ""
    echo "--- Session $COMPLETED terminee (exit code: $EXIT_CODE) ---"
    echo ""

    # Pause de 5 secondes entre les sessions pour laisser respirer
    sleep 5

    # Verifie si toutes les stories sont done/review dans sprint-status.yaml
    REMAINING=$(grep -c "ready-for-dev" _bmad-output/implementation-artifacts/sprint-status.yaml 2>/dev/null)
    if [ "$REMAINING" = "0" ]; then
        echo ""
        echo "=== TOUTES LES STORIES SONT TERMINEES ==="
        echo "$(date '+%Y-%m-%d %H:%M:%S')"
        break
    fi

    echo "Stories restantes: $REMAINING"
done

echo ""
echo "=== AUTO-PILOT TERMINE ==="
echo "Sessions executees: $COMPLETED"
