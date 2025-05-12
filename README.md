# rails-interview / TodoApi

[![Open in Coder](https://dev.crunchloop.io/open-in-coder.svg)](https://dev.crunchloop.io/templates/fly-containers/workspace?param.Git%20Repository=git@github.com:crunchloop/rails-interview.git)

This is a simple Todo List API built in Ruby on Rails 7. This project is currently being used for Ruby full-stack candidates.

## Build

To build the application:

`bin/setup`

## Run the API

To run the TodoApi in your local environment:

`bin/puma`

## Test

To run tests:

`bin/rspec`

Check integration tests at: (<https://github.com/crunchloop/interview-tests>)

## Contact

- Santiago Doldán (<sdoldan@crunchloop.io>)

## About Crunchloop

![crunchloop](https://s3.amazonaws.com/crunchloop.io/logo-blue.png)

We strongly believe in giving back :rocket:. Let's work together [`Get in touch`](https://crunchloop.io/#contact).

## 📦 Bulk Operations API

### Descripción

El módulo de **Bulk Operations** permite la creación y actualización masiva de listas de tareas (`TodoList`) y elementos (`Item`) relacionados, tanto de forma síncrona como asincrónica (en background).

---

## 🔧 Endpoints disponibles

### `POST /bulk/todo_lists`

Crea múltiples listas de tareas.

- **Body**:

  ```json
  {
    "todo_lists": [
      { "name": "Compras" },
      { "name": "Estudios" }
    ],
    "async": "true|false"
  }
  ```

- **Respuesta (async=true)**:

  ```json
  {
    "message": "Todo lists creation job enqueued",
    "job_id": "abc123"
  }
  ```

- **Respuesta (async=false)**:

  ```json
  {
    "message": "Successfully imported 2 todo lists"
  }
  ```

---

### `PUT /bulk/todo_lists`

Actualiza múltiples listas de tareas existentes.

- **Body**:

  ```json
  {
    "todo_lists": [
      { "id": 1, "name": "Compras editado" },
      { "id": 2, "name": "Estudios editado" }
    ],
    "async": "true|false"
  }
  ```

---

### `POST /bulk/items`

Crea múltiples `Items`.

- **Body**:

  ```json
  {
    "items": [
      { "todo_list_id": 1, "description": "Comprar leche" },
      { "todo_list_id": 1, "description": "Comprar pan" }
    ],
    "async": "true|false"
  }
  ```

---

### `PUT /bulk/items`

Actualiza múltiples `Items`.

- **Body**:

  ```json
  {
    "items": [
      { "id": 10, "description": "Leche deslactosada", "todo_list_id": 1 },
      { "id": 11, "description": "Pan integral", "todo_list_id": 1 }
    ],
    "async": "true|false"
  }
  ```

---

### `POST /bulk/todo_lists_with_items`

Crea listas de tareas junto con sus items en una sola transacción.

- **Body**:

  ```json
  {
    "todo_lists": [
      {
        "name": "Viaje",
        "items": [
          { "description": "Hacer maleta" },
          { "description": "Comprar boletos" }
        ]
      },
      {
        "name": "Mudanza",
        "items": [
          { "description": "Empacar cocina" }
        ]
      }
    ],
    "async": "true|false"
  }
  ```

---

## 🧠 Lógica de Servicio (`BulkOperationsService`)

### `bulk_create_todo_lists(todo_lists_attributes)`

- Crea objetos `TodoList` en masa usando `activerecord-import`.
- Devuelve:

  ```ruby
  {
    imported_count: <Integer>,
    failed_instances: <Array>,
    success: <Boolean>
  }
  ```

---

### `bulk_update_todo_lists(todo_lists_attributes)`

- Encuentra por `id`, actualiza y reimporta usando `on_duplicate_key_update`.
- Devuelve estadísticas de éxito o error por cada `TodoList`.

---

### `bulk_create_items(items_attributes)`

- Verifica existencia de la `todo_list` y crea `Item`s en lote.
- Maneja errores de validación y de relaciones faltantes.

---

### `bulk_update_items(items_attributes)`

- Actualiza múltiples `Item`s existentes.
- Aplica `on_duplicate_key_update`.

---

### `bulk_create_todo_lists_with_items(todo_lists_with_items)`

- Crea listas y sus ítems en una única transacción.
- Si algo falla, revierte la operación completa.

---

## 🧪 Consideraciones

- Usa `activerecord-import` para mejorar la eficiencia.
- Soporta modo asincrónico (mediante ActiveJob) para procesos pesados.
- Incluye validación y manejo de errores por instancia fallida.
