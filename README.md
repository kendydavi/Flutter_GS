# 🛰️ AgroSat Sentinel

**Plataforma de Monitoramento Agrícola via Dados Satelitais**

---

## Descrição da Solução

O AgroSat Sentinel é um aplicativo mobile desenvolvido em Flutter que democratiza o acesso a dados satelitais e agrometeorológicos para pequenos e médios produtores rurais brasileiros. A plataforma permite que produtores cadastrem suas áreas de lavoura — chamadas de **talhões** — e consultem, em tempo real, dados climáticos fornecidos pela **NASA POWER API**, incluindo temperatura, precipitação, umidade relativa e radiação solar.

O objetivo central é transformar informações técnicas de sensoriamento remoto e meteorologia em dados simples, acessíveis e acionáveis, sem custo de aquisição de imagens e sem exigir conhecimento técnico do usuário.

---

## Proposta da Aplicação

A indústria espacial gera volumes massivos de dados satelitais e agrometeorológicos diariamente, mas o acesso a essas informações ainda é restrito a grandes produtores e instituições com recursos técnicos e financeiros. O AgroSat Sentinel resolve esse problema criando uma interface acessível que consome diretamente a API pública da NASA (NASA POWER — Prediction Of Worldwide Energy Resources), serviço gratuito desenvolvido para aplicações agrícolas.

### Funcionalidades

- **Autenticação segura** com Firebase Authentication (cadastro e login por e-mail e senha)
- **Cadastro de talhões** com nome, cultura, área em hectares, coordenadas geográficas e status de saúde
- **Listagem em tempo real** dos talhões via Firestore, com atualização automática
- **Tela de detalhes** com dados agrometeorológicos consultados diretamente da NASA POWER API:
  - Temperatura máxima e mínima (°C)
  - Precipitação corrigida (mm)
  - Umidade relativa (%)
  - Radiação solar total (MJ/m²/dia)
- **Gestão de status** do talhão: Saudável, Atenção ou Crítico
- **Exclusão de talhões** com confirmação

### Tecnologias Utilizadas

| Tecnologia | Uso |
|---|---|
| Flutter | Framework cross-platform |
| Firebase Auth | Autenticação de usuários |
| Cloud Firestore | Persistência e stream de dados em tempo real |
| NASA POWER API | Dados agrometeorológicos por coordenada geográfica |
| Provider | Gerenciamento de estado (MVVM) |
| GetIt | Injeção de dependências |

### Arquitetura

O projeto segue a arquitetura **MVVM** com separação clara de responsabilidades:

```
lib/
├── core/                         # Configurações e injeção de dependências
├── data/
│   ├── services/                 # Comunicação com Firebase e NASA POWER API
│   └── repositories/             # Abstração entre services e ViewModels
├── domain/models/                # Modelos de domínio (TalhaoModel, WeatherModel)
└── presentation/
    ├── view_models/              # Lógica de negócio e estado das telas
    ├── widgets/                  # Componentes reutilizáveis
    └── (telas)                   # Login, Home, Detalhes, Cadastro
```

### API Utilizada

**NASA POWER (Prediction Of Worldwide Energy Resources)**
- Endpoint: `https://power.larc.nasa.gov/api/temporal/daily/point`
- Comunidade: `AG` (Agroclimatologia)
- Acesso: gratuito, sem necessidade de chave de API
- Dados fornecidos por coordenadas geográficas (latitude/longitude)

---

## Integrantes do Grupo

| Nome | RM |
|Davi Kendy Brandt Abe|553787|
| Vitória Ribeiro de Souza |552697|

---

## Link do Vídeo Pitch
(https://www.youtube.com/watch?v=I99yT6SBn2k)
