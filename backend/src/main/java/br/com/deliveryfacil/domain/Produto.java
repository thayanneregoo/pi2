package br.com.deliveryfacil.domain;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
@Entity @Table(name="PRODUTO")
public class Produto {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_produto") private Integer id;
 @NotBlank @Size(max=100) @Column(length=100,nullable=false) private String nome;
 @Column(length=500) private String descricao;
 @NotNull @DecimalMin("0.01") @Column(precision=10,scale=2) private BigDecimal preco;
 @NotBlank @Size(max=50) @Column(length=50,nullable=false) private String categoria;
 @Column(name="foto_url",length=255) private String fotoUrl;
 @Enumerated(EnumType.STRING) @Column(length=10,nullable=false) private StatusProduto status=StatusProduto.ATIVO;
 @Column(name="alterado_por") private Integer alteradoPor;
 @Column(name="atualizado_em",insertable=false,updatable=false) private LocalDateTime atualizadoEm;
 protected Produto(){}
 public Produto(String nome,String descricao,BigDecimal preco,String categoria,String fotoUrl){
  this.nome=nome;this.descricao=descricao;this.preco=preco;this.categoria=categoria;this.fotoUrl=fotoUrl;
 }
 public Integer getId(){return id;} public String getNome(){return nome;} public String getDescricao(){return descricao;}
 public BigDecimal getPreco(){return preco;} public String getCategoria(){return categoria;} public String getFotoUrl(){return fotoUrl;}
 public StatusProduto getStatus(){return status;}
 public void atualizar(String nome,String descricao,BigDecimal preco,String categoria,String fotoUrl){
  this.nome=nome;this.descricao=descricao;this.preco=preco;this.categoria=categoria;this.fotoUrl=fotoUrl;
 }
 public void pausar(){this.status=StatusProduto.PAUSADO;} public void ativar(){this.status=StatusProduto.ATIVO;}
}
