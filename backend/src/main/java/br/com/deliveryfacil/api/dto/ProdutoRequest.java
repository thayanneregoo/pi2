package br.com.deliveryfacil.api.dto;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
public record ProdutoRequest(@NotBlank @Size(max=100) String nome,
 @Size(max=500) String descricao,@NotNull @DecimalMin("0.01") BigDecimal preco,
 @NotBlank @Size(max=50) String categoria,@Size(max=255) String fotoUrl) {}
