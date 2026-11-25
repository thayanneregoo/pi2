package br.com.deliveryfacil.repository;
import br.com.deliveryfacil.domain.Pedido;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface PedidoRepository extends JpaRepository<Pedido,Integer> {
 List<Pedido> findAllByOrderByDataPedidoDesc();
}
