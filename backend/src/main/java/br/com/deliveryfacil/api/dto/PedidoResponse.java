package br.com.deliveryfacil.api.dto;
import br.com.deliveryfacil.domain.Pedido;
import java.math.BigDecimal;
public record PedidoResponse(Integer id,Integer idCliente,String status,String tipoEntrega,BigDecimal valorTotal) {
 public static PedidoResponse from(Pedido p){return new PedidoResponse(p.getId(),p.getCliente().getId(),p.getStatus().name(),p.getTipoEntrega().name(),p.getValorTotal());}
}
