package br.com.deliveryfacil.api;
import org.springframework.http.*;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import java.time.LocalDateTime;
import java.util.*;
@RestControllerAdvice
public class ApiExceptionHandler {
 @ExceptionHandler(ResponseStatusException.class)
 public ResponseEntity<Map<String,Object>> status(ResponseStatusException ex){
  return ResponseEntity.status(ex.getStatusCode()).body(Map.of("timestamp",LocalDateTime.now(),"status",ex.getStatusCode().value(),"erro",ex.getReason()==null?"Erro na requisição":ex.getReason()));
 }
 @ExceptionHandler(MethodArgumentNotValidException.class)
 public ResponseEntity<Map<String,Object>> validacao(MethodArgumentNotValidException ex){
  List<String> erros=ex.getBindingResult().getFieldErrors().stream().map(e->e.getField()+": "+e.getDefaultMessage()).toList();
  return ResponseEntity.badRequest().body(Map.of("timestamp",LocalDateTime.now(),"status",400,"erro","Dados inválidos","detalhes",erros));
 }
 @ExceptionHandler(Exception.class)
 public ResponseEntity<Map<String,Object>> inesperado(Exception ex){
  return ResponseEntity.status(500).body(Map.of("timestamp",LocalDateTime.now(),"status",500,"erro","Erro interno. Consulte os logs."));
 }
}
