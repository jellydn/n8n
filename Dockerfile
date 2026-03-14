FROM n8nio/n8n:latest

ENV NODE_ENV=production
ENV N8N_PROTOCOL=http
ENV WEBHOOK_URL=http://localhost:5678
ENV GENERIC_TIMEZONE=UTC

EXPOSE 5678

USER node

ENTRYPOINT ["tini", "--", "n8n"]
