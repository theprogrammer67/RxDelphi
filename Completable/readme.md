# TCompletable

Класс позволяет упростить разработку приложений, использующих асинхронный код. Использование асинхронного кода позволяет избежать "заморозки" UI приложения во время выполнения запросов к БД или сети.

Класс использует концепцию RactiveX, но не являтся точной реализацией одноименного класса в RactiveX.

Класс имеет всего два метода - Create и Subscribe. В параметрах конструктора Create задается метод или функция, которая будет выполнена в отдельном потоке и вернет данные определеного типа. Как правило, это запрос к БД или запрос по сети (REST). В параметрах метода Subscribe задается метод или процедура "наблюдателя", которая будет выполнена в основном потоке после получения результата выполнения метода, заданного в Create. Выполнение начинается после вызова метода Subscribe.

Класс TCompletable для удобства не требует явного освобождения памяти и создания для этого ссылки на объект класса. Он сам освобождает память после выполнения метода Subscribe.

Еще одной удобной особенностью класса является возможность его привязки к контексту. В качестве контекста может выступать любой потомок класса TComponent, как правило - TForm. В случае, если в конструкторе передан контекст, обхект TCompletable будет учитывать жизненный цикл контекста. Если на момент выполнения метода получения данных, переданного в конструкторе, объект контекста уже уничтожен (форма закрыта), TCompletable не будет пытаться обращаться к ней, вызывая методы, переданные в параметрах Subscribe и корректно завершит работу и освободит память.

Основное назначение TCompletable - реализовать асинхронное обновление данных компонентов на TForm в случаях, когда получение данных может занимать продолжительное время. По аналогии обновления HTML-страниц в веб браузере. 

## Примеры  использования:

### Минимальный

```pascal
TComplectable<TResponseData>
    .Create(Self, ExecuteMeth)
    .Subscribe(CompleteMeth);
```
### Максимальный

```pascal
   TComplectable<TUsers>
    .Create(Self,
      function: TUsers
      begin
        Result := GetsUserList;
      end)
    .Subscribe(
      procedure(AValue: TUsers)
      begin
       UpdateListView(AValue);
      end,
      procedure(E: Exception)
      begin
       ShowMessage(E.Message);
      end);
```