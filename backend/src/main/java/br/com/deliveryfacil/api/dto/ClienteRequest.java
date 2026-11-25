package br.com.deliveryfacil.api.dto;
import jakarta.validation.constraints.*;
public record ClienteRequest(@NotBlank @Size(max=100) String nome,
 @NotBlank @Pattern(regexp="[0-9]{10,15}",message="Informe telefone com DDD, somente números.")
 String telefone, @Email @Size(max=150) String email) {}
