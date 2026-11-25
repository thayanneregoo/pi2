package br.com.deliveryfacil.api;
import br.com.deliveryfacil.api.dto.*;
import br.com.deliveryfacil.service.ClienteService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import java.util.List;
@RestController @RequestMapping("/api/clientes")
public class ClienteController {
 private final ClienteService service;
 public ClienteController(ClienteService service){this.service=service;}
 @PostMapping @ResponseStatus(HttpStatus.CREATED) public ClienteResponse criar(@Valid @RequestBody ClienteRequest r){return service.criar(r);}
 @GetMapping public List<ClienteResponse> listar(){return service.listar();}
 @GetMapping("/{id}") public ClienteResponse buscar(@PathVariable Integer id){return service.buscar(id);}
 @PutMapping("/{id}") public ClienteResponse atualizar(@PathVariable Integer id,@Valid @RequestBody ClienteRequest r){return service.atualizar(id,r);}
 @DeleteMapping("/{id}") @ResponseStatus(HttpStatus.NO_CONTENT) public void excluir(@PathVariable Integer id){service.excluir(id);}
}
