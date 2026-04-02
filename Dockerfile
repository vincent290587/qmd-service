FROM oven/bun:latest

# Install build essentials
RUN apt-get update && apt-get install -y python3 make g++ socat && rm -rf /var/lib/apt/lists/*

WORKDIR /app/source

# Copy dependency files first
COPY qmd/package.json qmd/bun.lockb* ./
RUN bun install

# Copy the rest of the source
COPY qmd/ .

# IMPORTANT: Compile the TypeScript to JavaScript (creates the /dist folder)
RUN bun run build

# Link the package so 'qmd' works globally
RUN bun link

# Setup data directories
WORKDIR /app
RUN mkdir -p /docs /root/.config/qmd /root/.cache/qmd

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 8181
ENTRYPOINT ["/app/entrypoint.sh"]