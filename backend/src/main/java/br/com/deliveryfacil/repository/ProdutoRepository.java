package br.com.deliveryfacil.repository;
import br.com.deliveryfacil.domain.*;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface ProdutoRepository extends JpaRepository<Produto,Integer> {
 List<Produto> findByStatus(StatusProduto status);
}
