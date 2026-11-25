package br.com.deliveryfacil.api.dto;
import br.com.deliveryfacil.domain.StatusPedido;
import jakarta.validation.constraints.NotNull;
public record StatusPedidoRequest(@NotNull StatusPedido status, String motivo) {}
