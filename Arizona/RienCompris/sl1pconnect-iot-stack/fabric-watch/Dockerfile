FROM grafana/grafana:11.1.0

# pas de docker.sock — supprimé (était une escalade de privilèges critique)
# Grafana tourne déjà en tant que utilisateur grafana (uid 472) par défaut

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/api/health || exit 1
