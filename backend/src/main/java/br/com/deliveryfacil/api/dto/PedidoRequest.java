package br.com.deliveryfacil.api.dto;
import br.com.deliveryfacil.domain.TipoEntrega;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
public record PedidoRequest(@NotNull Integer idCliente, Integer idEndereco,
 @NotNull TipoEntrega tipoEntrega, @NotNull @DecimalMin("0.00") BigDecimal taxaEntrega) {}
