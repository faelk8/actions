<h1 align="center">
  <img src="imagem/actions.png" alt="Kubernetes" width=300px height=150px >
  <br>
</h1>

# Criando a Aplicação
Uma função de soma simples em go.<br>
`math.go`
```
package main

import "fmt"

func main() {
	fmt.Println(soma(112, 10))
}

func soma(a int, b int) int {
	return a + b
}
```
Essa parte faz uma verificação em busca de erro.<br>
`math_test.go`
```
package main

import "testing"

func TestSoma(t *testing.T) {

	total := soma(15, 15)

	if total != 30 {
		t.Errorf("Resultado da some é inválido: Resultado %d. Esperado: %d", total, 30)
	}
}
```

# Criar o repositório
Crair o repositório.
```
git init 
git branch -M main
  # ...
```
Com os arquivo da api pronto, cria uma pasta `.github/workflow` contendo o arquivo `ci.yaml`, neste arquivo vai ter as configurações para testar a aplicação.<br>
* No arquivo contém as instruções para rodar a aplicação em uma máquina Ubuntu e 
testar o código Go.<br>

`ci.yaml`
```
name: ci-golang-workflow
on: [push]
jobs:
  check-application:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
        with:
          go-version: 1.15
      - run: go test
      - run: go run math.go
```
Quando enviar os novos arquivos junto com o `ci.yaml`, o GitHub Actions vai testar o código.
* Ajustar as configurações para as regras e proteções as branchs.

# Ajustando o Código
Todas as vezes que subir algo para a branch develop o código vai ser testado.<br>
`ci.yaml`
```
name: ci-golang-workflow
on: 
  pull_request:
    branches: 
      - develop
jobs:
  check-application:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
        with:
          go-version: 1.15
      - run: go test
      - run: go run math.go
```

# Strategy
Difindo em quais versões do Go o código vai ser testado.<br>
`ci.yaml`
```
name: ci-golang-workflow
on: 
  pull_request:
    branches: 
      - develop

strategy:
  matrix:
    go: ['1.14','1.15']

jobs:
  check-application:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
        with:
          go-version:  ${{matrix.go}}
      - run: go test
      - run: go run math.go
```

# Criado a Imagem de Teste
`Dockerfile`
```
FROM golang:1.19

WORKDIR /app

RUN go mod init math

COPY . .

RUN go build -o math

CMD ["./math"]
```

# Criando Imagem
[Build and Pusch Docker](https://github.com/marketplace/actions/build-and-push-docker-images)<br>
Ajustando o código.<br>
`ci.yaml`
```
...
jobs:
  check-application:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        go: ['1.14','1.15']
        
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-go@v2
        with:
          go-version:  ${{matrix.go}}
      - run: go test
      - run: go run math.go

    # Criando a imagem dentro do github
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      # - name: Login to Docker Hub
      #   uses: docker/login-action@v3
      #   with:
      #     username: ${{ secrets.DOCKERHUB_USERNAME }}
      #     password: ${{ secrets.DOCKERHUB_TOKEN }}
      - name: Build and push
        uses: faelk8/build-push-action@v5
        with:
          push: false #true para salvar no docker hub
          tags: faelk8/actions:latest
```


# Comandos
| git checkout -b feature/github-matrix | | 