package br.com.deliveryfacil.api.dto;
import br.com.deliveryfacil.domain.Produto;
import java.math.BigDecimal;
public record ProdutoResponse(Integer id,String nome,String descricao,BigDecimal preco,String categoria,String fotoUrl,String status) {
 public static ProdutoResponse from(Produto p){return new ProdutoResponse(p.getId(),p.getNome(),p.getDescricao(),p.getPreco(),p.getCategoria(),p.getFotoUrl(),p.getStatus().name());}
}
