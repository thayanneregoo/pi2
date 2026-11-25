package br.com.deliveryfacil.domain;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.time.LocalDateTime;
@Entity @Table(name="CLIENTE", uniqueConstraints=@UniqueConstraint(name="UQ_CLIENTE_TELEFONE", columnNames="telefone"))
public class Cliente extends Pessoa {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_cliente") private Integer id;
 @NotBlank @Pattern(regexp="[0-9]{10,15}") @Size(max=15) @Column(length=15,nullable=false) private String telefone;
 @Email @Size(max=150) @Column(length=150) private String email;
 @Column(name="telefone_verificado", nullable=false) private boolean telefoneVerificado;
 @Column(name="anonimizado",nullable=false) private boolean anonimizado;
 @Column(name="criado_em", insertable=false, updatable=false) private LocalDateTime criadoEm;
 protected Cliente() {}
 public Cliente(String nome,String telefone,String email){super(nome);this.telefone=telefone;this.email=email;this.telefoneVerificado=false;}
 public Integer getId(){return id;} public String getTelefone(){return telefone;}
 public String getEmail(){return email;} public boolean isTelefoneVerificado(){return telefoneVerificado;}
 public void atualizar(String nome,String email){alterarNome(nome);this.email=email;}
 public void marcarTelefoneVerificado(){this.telefoneVerificado=true;}
 public void anonimizar(){this.nome="Cliente removido";this.telefone=String.format("%010d", 9000000000L + id);this.email=null;this.telefoneVerificado=false;this.anonimizado=true;}
}
