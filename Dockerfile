# Versão do go
FROM golang:1.19

# Diretorio
WORKDIR /app

# Copiando 
COPY . .

# Criando a imagem com o nome de math
RUN go build -o math

# Rodando
CMD ["./math"]