package br.com.deliveryfacil.api;
import br.com.deliveryfacil.api.dto.*;
import br.com.deliveryfacil.service.PedidoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import java.util.List;
@RestController @RequestMapping("/api/pedidos")
public class PedidoController {
 private final PedidoService service;
 public PedidoController(PedidoService service){this.service=service;}
 @PostMapping @ResponseStatus(HttpStatus.CREATED) public PedidoResponse criar(@Valid @RequestBody PedidoRequest r){return service.criar(r);}
 @GetMapping public List<PedidoResponse> listar(){return service.listar();}
 @GetMapping("/{id}") public PedidoResponse buscar(@PathVariable Integer id){return service.buscar(id);}
 @PatchMapping("/{id}/status") public PedidoResponse status(@PathVariable Integer id,@Valid @RequestBody StatusPedidoRequest r){return service.atualizarStatus(id,r);}
}
