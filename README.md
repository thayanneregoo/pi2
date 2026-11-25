# DeliveryFácil — Projeto Integrador

## Estrutura
- `database/01_deliveryfacil.sql`: SQL Server, tabelas, constraints, dados, consultas, índices, function, triggers e stored procedure.
- `backend/`: API REST Java 17 + Spring Boot 3.4 + Spring Data JPA + Bean Validation + SQL Server.
- `DOCUMENTACAO_EXPLICATIVA.docx`: guia de arquitetura, execução, regras e limites do MVP.

## Banco
1. Abra o SQL Server Management Studio (SSMS).
2. Execute `database/01_deliveryfacil.sql` em SQL Server 2019+.
3. O script cria a base `DeliveryFacil` e os dados demonstrativos.

## API
Pré-requisitos: JDK 17+, Maven 3.9+ e SQL Server.
1. Configure `DB_URL`, `DB_USERNAME` e `DB_PASSWORD`.
2. Entre na pasta `backend`.
3. Execute `mvn spring-boot:run`.
4. API em `http://localhost:8080`.

### Endpoints implementados
| Método | Rota | Finalidade |
|---|---|---|
| POST | `/api/clientes` | Cadastrar cliente |
| GET | `/api/clientes` | Listar clientes |
| GET | `/api/clientes/{id}` | Consultar cliente |
| PUT | `/api/clientes/{id}` | Atualizar nome/e-mail sem trocar telefone |
| DELETE | `/api/clientes/{id}` | Anonimizar dados pessoais preservando histórico |
| POST | `/api/produtos` | Cadastrar produto |
| GET | `/api/produtos?somenteAtivos=true` | Listar cardápio |
| GET | `/api/produtos/{id}` | Consultar produto |
| PUT | `/api/produtos/{id}` | Atualizar produto |
| PATCH | `/api/produtos/{id}/disponibilidade?ativo=false` | Pausar/ativar produto |
| DELETE | `/api/produtos/{id}` | Excluir produto quando não houver vínculo |
| POST | `/api/pedidos` | Criar pedido |
| GET | `/api/pedidos` | Listar pedidos |
| GET | `/api/pedidos/{id}` | Consultar pedido |
| PATCH | `/api/pedidos/{id}/status` | Avançar status validando o fluxo |

Exemplo de cliente:
```json
{"nome":"Maria Santos","telefone":"81999998888","email":"maria@email.com"}
```
Exemplo de pedido de retirada (telefone precisa estar verificado):
```json
{"idCliente":1000,"idEndereco":null,"tipoEntrega":"RETIRADA","taxaEntrega":0.00}
```
Exemplo de status:
```json
{"status":"PAGAMENTO_APROVADO"}
```

## Limites explícitos desta entrega
O banco contempla o modelo de dados completo. A API implementa o núcleo inicial (clientes, produtos e pedidos) para demonstrar REST, POO, validação, regras de domínio e persistência. Endereços, grupos/opções, itens, pagamentos com gateway/webhook, avaliações, autenticação/autorização, notificações, OTP real, cálculo geográfico e integração de mapas ainda precisam de implementação e credenciais externas. Não apresentar pagamento real como pronto.
"# pi2" 
