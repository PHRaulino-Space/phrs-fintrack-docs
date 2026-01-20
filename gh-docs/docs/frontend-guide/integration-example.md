```typescript
import axios from "axios"
import { useAuth } from "@/hooks/use-auth" // Exemplo de hook real do projeto

// Criação da instância Axios com baseURL do .env
const api = axios.create({
  baseURL: `${process.env.NEXT_PUBLIC_API_BASE_URL}${process.env.NEXT_PUBLIC_API_PREFIX || ""}`,
  withCredentials: true,
  headers: {
    "Content-Type": "application/json",
  },
})

// Interceptor de Requisição: Injeção do Workspace ID
// Este padrão é crucial para o sistema multi-tenant funcionar
api.interceptors.request.use(
  (config) => {
    // Acessa o estado global do Zustand fora de componentes React
    const activeWorkspace = useAuth.getState().activeWorkspace

    if (activeWorkspace) {
      config.headers["X-Workspace-ID"] = activeWorkspace.id
    }

    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Interceptor de Resposta: Tratamento de Erros Globais
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // Redirecionamento automático em caso de token expirado
    if (error.response && error.response.status === 401) {
       useAuth.getState().logout()
       if (typeof window !== "undefined" && !window.location.pathname.includes("/login")) {
         window.location.href = "/login"
       }
    }
    return Promise.reject(error)
  }
)

export default api
```
