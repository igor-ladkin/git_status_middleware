## Rack Middleware to include git info into response body

### How to run

```
git clone git@github.com:thrasherDGK/git_status_middleware.git
cd git_status_middleware
bundle install
rackup
```

### Git Status Middleware

Во время разработки приходится сталкиваться с ситуацией, когда необходимо для профилирования оперативно определить, в какой ветке находишься и какая текущая ревизия кода.

Для решения этой задачи необходимо написать Rack middleware, который добавляет в отрендеренную страницу панель с актуальной Git-информацией: текущую ветку и ревизию, число измененных, неотслеживаемых и застейдженых файлов.

Если git не установлен или репозиторий не инициализирован, то выводит сообщение об этом.
