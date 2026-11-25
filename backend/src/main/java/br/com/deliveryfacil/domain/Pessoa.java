package br.com.deliveryfacil.domain;
import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/** Base comum para pessoas cadastradas no sistema; não vira tabela própria. */
@MappedSuperclass
public abstract class Pessoa {
 @NotBlank @Size(max=100) @Column(name="nome",length=100,nullable=false)
 protected String nome;
 protected Pessoa() {}
 protected Pessoa(String nome){this.nome=nome;}
 public String getNome(){return nome;}
 public void alterarNome(String nome){this.nome=nome;}
}
