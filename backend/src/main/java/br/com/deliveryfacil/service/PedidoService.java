package br.com.deliveryfacil.service;
import br.com.deliveryfacil.api.dto.*;
import br.com.deliveryfacil.domain.*;
import br.com.deliveryfacil.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import java.util.List;
@Service
public class PedidoService {
 private final PedidoRepository pedidos; private final ClienteRepository clientes;
 public PedidoService(PedidoRepository pedidos,ClienteRepository clientes){this.pedidos=pedidos;this.clientes=clientes;}
 @Transactional public PedidoResponse criar(PedidoRequest r){
  Cliente c=clientes.findById(r.idCliente()).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"Cliente não encontrado."));
  if(!c.isTelefoneVerificado()) throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY,"Verifique o telefone antes de confirmar o pedido.");
  if(r.tipoEntrega()==TipoEntrega.ENTREGA && r.idEndereco()==null) throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Endereço é obrigatório para entrega.");
  if(r.tipoEntrega()==TipoEntrega.RETIRADA && (r.idEndereco()!=null || r.taxaEntrega().signum()!=0)) throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Retirada não utiliza endereço nem taxa de entrega.");
  return PedidoResponse.from(pedidos.save(new Pedido(c,r.idEndereco(),r.tipoEntrega(),r.taxaEntrega())));
 }
 @Transactional(readOnly=true) public List<PedidoResponse> listar(){return pedidos.findAllByOrderByDataPedidoDesc().stream().map(PedidoResponse::from).toList();}
 @Transactional(readOnly=true) public PedidoResponse buscar(Integer id){return PedidoResponse.from(obter(id));}
 @Transactional public PedidoResponse atualizarStatus(Integer id,StatusPedidoRequest r){
  Pedido p=obter(id);
  if(r.status()==StatusPedido.CANCELADO && (r.motivo()==null || r.motivo().isBlank()))
   throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Motivo obrigatório para cancelamento.");
  try{p.atualizarStatus(r.status());}catch(IllegalStateException ex){throw new ResponseStatusException(HttpStatus.CONFLICT,ex.getMessage());}
  return PedidoResponse.from(p);
 }
 private Pedido obter(Integer id){return pedidos.findById(id).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"Pedido não encontrado."));}
}
