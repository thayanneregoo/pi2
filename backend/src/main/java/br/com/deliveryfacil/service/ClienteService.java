package br.com.deliveryfacil.service;
import br.com.deliveryfacil.api.dto.*;
import br.com.deliveryfacil.domain.Cliente;
import br.com.deliveryfacil.repository.ClienteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import java.util.List;
@Service
public class ClienteService {
 private final ClienteRepository repo;
 public ClienteService(ClienteRepository repo){this.repo=repo;}
 @Transactional public ClienteResponse criar(ClienteRequest r){
  if(repo.existsByTelefone(r.telefone())) throw new ResponseStatusException(HttpStatus.CONFLICT,"Telefone já cadastrado.");
  return ClienteResponse.from(repo.save(new Cliente(r.nome(),r.telefone(),r.email())));
 }
 @Transactional(readOnly=true) public List<ClienteResponse> listar(){return repo.findAll().stream().map(ClienteResponse::from).toList();}
 @Transactional(readOnly=true) public ClienteResponse buscar(Integer id){return ClienteResponse.from(obter(id));}
 @Transactional public ClienteResponse atualizar(Integer id,ClienteRequest r){
  Cliente c=obter(id); if(!c.getTelefone().equals(r.telefone())) throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Este endpoint não altera telefone; use fluxo de verificação.");
  c.atualizar(r.nome(),r.email()); return ClienteResponse.from(c);
 }
 @Transactional public void excluir(Integer id){obter(id).anonimizar();}
 private Cliente obter(Integer id){return repo.findById(id).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"Cliente não encontrado."));}
}
