package br.com.deliveryfacil.domain;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
@Entity @Table(name="PEDIDO")
public class Pedido {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_pedido") private Integer id;
 @ManyToOne(fetch=FetchType.LAZY) @JoinColumn(name="id_cliente",nullable=false) private Cliente cliente;
 @Column(name="id_endereco") private Integer idEndereco;
 @Enumerated(EnumType.STRING) @Column(name="tipo_entrega",length=10,nullable=false) private TipoEntrega tipoEntrega;
 @Column(name="data_pedido",insertable=false,updatable=false) private LocalDateTime dataPedido;
 @Enumerated(EnumType.STRING) @Column(length=30,nullable=false) private StatusPedido status=StatusPedido.PENDENTE;
 @Column(name="subtotal_produtos",precision=10,scale=2,nullable=false) private BigDecimal subtotalProdutos=BigDecimal.ZERO;
 @Column(name="taxa_entrega",precision=10,scale=2,nullable=false) private BigDecimal taxaEntrega=BigDecimal.ZERO;
 @Column(name="desconto_cupom",precision=10,scale=2,nullable=false) private BigDecimal descontoCupom=BigDecimal.ZERO;
 @Column(name="valor_total",precision=10,scale=2,nullable=false) private BigDecimal valorTotal=BigDecimal.ZERO;
 protected Pedido(){}
 public Pedido(Cliente cliente,Integer idEndereco,TipoEntrega tipoEntrega,BigDecimal taxa){
  this.cliente=cliente;this.idEndereco=idEndereco;this.tipoEntrega=tipoEntrega;this.taxaEntrega=taxa;
 }
 public Integer getId(){return id;} public StatusPedido getStatus(){return status;} public BigDecimal getValorTotal(){return valorTotal;}
 public Cliente getCliente(){return cliente;} public TipoEntrega getTipoEntrega(){return tipoEntrega;}
 public void atualizarStatus(StatusPedido novo){
  if(status==StatusPedido.ENTREGUE || status==StatusPedido.CANCELADO) throw new IllegalStateException("Pedido encerrado.");
  boolean permitido=switch(status){
   case PENDENTE -> novo==StatusPedido.PAGAMENTO_APROVADO || novo==StatusPedido.CANCELADO;
   case PAGAMENTO_APROVADO -> novo==StatusPedido.ACEITO || novo==StatusPedido.CANCELADO;
   case ACEITO -> novo==StatusPedido.EM_PREPARO || novo==StatusPedido.CANCELADO;
   case EM_PREPARO -> novo==StatusPedido.PRONTO || novo==StatusPedido.CANCELADO;
   case PRONTO -> novo==StatusPedido.SAIU_PARA_ENTREGA || novo==StatusPedido.ENTREGUE || novo==StatusPedido.CANCELADO;
   case SAIU_PARA_ENTREGA -> novo==StatusPedido.ENTREGUE || novo==StatusPedido.CANCELADO;
   default -> false;
  };
  if(!permitido) throw new IllegalStateException("Transição de status não permitida.");
  this.status=novo;
 }
}
