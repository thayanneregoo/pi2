package br.com.deliveryfacil.api.dto;
import br.com.deliveryfacil.domain.Cliente;
public record ClienteResponse(Integer id,String nome,String telefone,String email,boolean telefoneVerificado) {
 public static ClienteResponse from(Cliente c){return new ClienteResponse(c.getId(),c.getNome(),c.getTelefone(),c.getEmail(),c.isTelefoneVerificado());}
}
