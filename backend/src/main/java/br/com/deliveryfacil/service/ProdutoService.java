package br.com.deliveryfacil.service;
import br.com.deliveryfacil.api.dto.*;
import br.com.deliveryfacil.domain.*;
import br.com.deliveryfacil.repository.ProdutoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import java.util.List;
@Service
public class ProdutoService {
 private final ProdutoRepository repo;
 public ProdutoService(ProdutoRepository repo){this.repo=repo;}
 @Transactional public ProdutoResponse criar(ProdutoRequest r){
  return ProdutoResponse.from(repo.save(new Produto(r.nome(),r.descricao(),r.preco(),r.categoria(),r.fotoUrl())));
 }
 @Transactional(readOnly=true) public List<ProdutoResponse> listar(boolean somenteAtivos){
  return (somenteAtivos?repo.findByStatus(StatusProduto.ATIVO):repo.findAll()).stream().map(ProdutoResponse::from).toList();
 }
 @Transactional(readOnly=true) public ProdutoResponse buscar(Integer id){return ProdutoResponse.from(obter(id));}
 @Transactional public ProdutoResponse atualizar(Integer id,ProdutoRequest r){
  Produto p=obter(id);p.atualizar(r.nome(),r.descricao(),r.preco(),r.categoria(),r.fotoUrl());return ProdutoResponse.from(p);
 }
 @Transactional public ProdutoResponse alterarDisponibilidade(Integer id,boolean ativo){
  Produto p=obter(id);if(ativo)p.ativar();else p.pausar();return ProdutoResponse.from(p);
 }
 @Transactional public void excluir(Integer id){repo.delete(obter(id));}
 private Produto obter(Integer id){return repo.findById(id).orElseThrow(()->new ResponseStatusException(HttpStatus.NOT_FOUND,"Produto não encontrado."));}
}
