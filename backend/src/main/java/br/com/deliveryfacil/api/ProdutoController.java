package br.com.deliveryfacil.api;
import br.com.deliveryfacil.api.dto.*;
import br.com.deliveryfacil.service.ProdutoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import java.util.List;
@RestController @RequestMapping("/api/produtos")
public class ProdutoController {
 private final ProdutoService service;
 public ProdutoController(ProdutoService service){this.service=service;}
 @PostMapping @ResponseStatus(HttpStatus.CREATED) public ProdutoResponse criar(@Valid @RequestBody ProdutoRequest r){return service.criar(r);}
 @GetMapping public List<ProdutoResponse> listar(@RequestParam(defaultValue="false") boolean somenteAtivos){return service.listar(somenteAtivos);}
 @GetMapping("/{id}") public ProdutoResponse buscar(@PathVariable Integer id){return service.buscar(id);}
 @PutMapping("/{id}") public ProdutoResponse atualizar(@PathVariable Integer id,@Valid @RequestBody ProdutoRequest r){return service.atualizar(id,r);}
 @PatchMapping("/{id}/disponibilidade") public ProdutoResponse disponibilidade(@PathVariable Integer id,@RequestParam boolean ativo){return service.alterarDisponibilidade(id,ativo);}
 @DeleteMapping("/{id}") @ResponseStatus(HttpStatus.NO_CONTENT) public void excluir(@PathVariable Integer id){service.excluir(id);}
}
