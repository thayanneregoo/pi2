package br.com.deliveryfacil.domain;
import jakarta.persistence.*;
@Entity @Table(name="FUNCIONARIO")
public class Funcionario extends Pessoa {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_funcionario")
 private Integer id;
 @Column(length=20,nullable=false) private String papel;
 @Column(nullable=false) private boolean ativo=true;
 protected Funcionario(){}
 public Funcionario(String nome,String papel){super(nome);this.papel=papel;}
 public Integer getId(){return id;} public String getPapel(){return papel;} public boolean isAtivo(){return ativo;}
 public void desativar(){this.ativo=false;}
}
