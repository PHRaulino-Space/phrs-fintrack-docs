# Controllers (Handlers)

Os controllers (ou handlers HTTP) são a porta de entrada da API. Eles residem em `internal/controller/http/v1`.

## Responsabilidades
1.  **Parse Request**: Ler JSON do body, Query Params ou Path Variables.
2.  **Validação**: Verificar se os dados obrigatórios estão presentes.
3.  **Chamada do UseCase**: Invocar a lógica de negócio.
4.  **Response**: Formatar a resposta (JSON) e o código HTTP adequado (200, 201, 400, 500).

## Exemplo (`account.go`)

```go
func (r *accountRoutes) create(c *gin.Context) {
    var request entity.Account
    if err := c.ShouldBindJSON(&request); err != nil {
        r.l.Error(err, "http - v1 - createAccount")
        errorResponse(c, http.StatusBadRequest, "invalid request body")
        return
    }

    account, err := r.u.Create(c.Request.Context(), request)
    if err != nil {
        r.l.Error(err, "http - v1 - createAccount")
        errorResponse(c, http.StatusInternalServerError, "database problem")
        return
    }

    c.JSON(http.StatusCreated, account)
}
```
