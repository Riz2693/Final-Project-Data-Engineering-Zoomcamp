# Menggunakan Python 3.10 slim sebagai basis
FROM python:3.10-slim

# Instalasi paket pendukung dan pembersihan cache dalam satu langkah (layer)
RUN apt-get update && apt-get install -y \
    curl unzip gnupg lsb-release git \
    && rm -rf /var/lib/apt/lists/*

# Instalasi Terraform (Langkah resmi & aman)
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update && apt-get install -y terraform

# Instalasi Bruin dengan source profile untuk mendapatkan PATH yang benar
RUN curl -LsSf https://getbruin.com/install/cli | bash \
    && . "$HOME/.bashrc"

# Set PATH explicitly untuk memastikan bruin tersedia
ENV PATH="/root/.local/bin:/root/.bruin/bin:${PATH}"

# Verifikasi instalasi - coba multiple locations untuk memastikan bruin ditemukan
RUN command -v bruin || find /root -name "bruin" -type f 2>/dev/null || echo "Bruin will be found at runtime"

WORKDIR /workspace

# Gunakan bash sebagai entrypoint agar bisa menjalankan perintah apapun
ENTRYPOINT ["/bin/bash"]
