# Testes Backend

## Unit Tests

Testamos a lógica de negócio isolando as dependências externas (DB).

```go
func TestCreateAccount(t *testing.T) {
    // Setup Mock Controller
    ctrl := gomock.NewController(t)
    defer ctrl.Finish()

    mockRepo := mocks.NewMockAccountRepo(ctrl)
    useCase := NewAccountUseCase(mockRepo)

    // Expectations
    mockRepo.EXPECT().Create(gomock.Any(), gomock.Any()).Return(nil)

    // Execute
    err := useCase.Create(context.Background(), &entity.Account{Name: "Test"})

    // Assert
    assert.NoError(t, err)
}
```

## Integration Tests

Testes que batem no banco real (frequentemente usando Docker containers efêmeros para o teste). Verificam se o SQL está correto.
