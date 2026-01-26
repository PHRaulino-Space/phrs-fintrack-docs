```go
package v1

import (
	"net/http"
	"github.com/gin-gonic/gin"
	"github.com/phraulino/fintrack/internal/entity"
)

// Exemplo real de um Controller (Handler) no backend

func (r *accountRoutes) create(c *gin.Context) {
    var request entity.Account

    // 1. Bind JSON do corpo da requisição para a struct
    if err := c.ShouldBindJSON(&request); err != nil {
        r.l.Error(err, "http - v1 - createAccount")
        errorResponse(c, http.StatusBadRequest, "invalid request body")
        return
    }

    // 2. Chama o UseCase (Regra de Negócio)
    // O Contexto é passado para permitir cancelamento e tracing
    account, err := r.u.Create(c.Request.Context(), request)
    if err != nil {
        r.l.Error(err, "http - v1 - createAccount")
        errorResponse(c, http.StatusInternalServerError, "database problem")
        return
    }

    // 3. Retorna 201 Created com o objeto criado
    c.JSON(http.StatusCreated, account)
}
```
