package br.com.deliveryfacil.repository;
import br.com.deliveryfacil.domain.Cliente;
import org.springframework.data.jpa.repository.JpaRepository;
public interface ClienteRepository extends JpaRepository<Cliente,Integer> {
 boolean existsByTelefone(String telefone);
}
