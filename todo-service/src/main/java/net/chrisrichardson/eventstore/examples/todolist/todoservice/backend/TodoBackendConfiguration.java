package net.chrisrichardson.eventstore.examples.todolist.todoservice.backend;

import io.eventuate.javaclient.spring.EnableEventHandlers;
import io.eventuate.sync.AggregateRepository;
import io.eventuate.sync.EventuateAggregateStore;
import net.chrisrichardson.eventstore.examples.todolist.TodoRepository;
import net.chrisrichardson.eventstore.examples.todolist.todoservice.backend.command.TodoCommand;
import net.chrisrichardson.eventstore.examples.todolist.todoservice.backend.domain.TodoAggregate;
import net.chrisrichardson.eventstore.examples.todolist.todoservice.backend.domain.TodoBulkDeleteAggregate;
import net.chrisrichardson.eventstore.examples.todolist.todoservice.backend.domain.TodoEventSubscriber;
import net.chrisrichardson.eventstore.examples.todolist.todoservice.backend.domain.TodoService;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;


@Configuration
@EntityScan("net.chrisrichardson.eventstore.examples.todolist")
@EnableJpaRepositories("net.chrisrichardson.eventstore.examples.todolist")
@EnableEventHandlers
public class TodoBackendConfiguration {

  @Bean
  public TodoEventSubscriber todoEventSubscriber() {
    return new TodoEventSubscriber();
  }

  @Bean
  public AggregateRepository<TodoAggregate, TodoCommand> aggregateRepository(EventuateAggregateStore eventStore) {
    return new AggregateRepository<>(TodoAggregate.class, eventStore);
  }

  @Bean
  public AggregateRepository<TodoBulkDeleteAggregate, TodoCommand> bulkDeleteAggregateRepository(EventuateAggregateStore eventStore) {
    return new AggregateRepository<>(TodoBulkDeleteAggregate.class, eventStore);
  }

  @Bean
  public TodoService updateService(AggregateRepository<TodoAggregate, TodoCommand> aggregateRepository, AggregateRepository<TodoBulkDeleteAggregate, TodoCommand> bulkDeleteAggregateRepository) {
    return new TodoService(aggregateRepository, bulkDeleteAggregateRepository);
  }

  @Bean
  public TodoViewServiceImpl commandService(TodoRepository repository) {
    return new TodoViewServiceImpl(repository);
  }


}
