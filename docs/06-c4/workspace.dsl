workspace "Служба такси" "Учебная модель" {

    model {
        // 1. Акторы
        client = person "Клиент" "Заказывает поездки, оплачивает, оценивает"
        driver = person "Водитель" "Принимает заказы, выполняет поездки"

        // 2. Внешние системы
        payment_gw = softwareSystem "Платёжный шлюз" "Проводит оплату и возвраты" "Внешняя"
        maps_api   = softwareSystem "Картографический сервис" "Строит маршруты, считает расстояние" "Внешняя"
        sms_gw     = softwareSystem "SMS-шлюз" "Отправляет уведомления" "Внешняя"

        // 3. Ваша система и её контейнеры
        taxi_system = softwareSystem "Служба такси" "Заказ поездок, подбор водителей, расчёт стоимости" {
            
            mobile_app = container "Мобильное приложение" "Интерфейс для клиента" "React Native"
            driver_app = container "Приложение водителя" "Интерфейс для водителя" "Flutter"
            api_gateway = container "API Gateway" "Маршрутизация и авторизация" "Nginx"
            
            backend = container "Сервер заказов" "Бизнес-логика, управление заказами" "Kotlin / Spring Boot" {
                // Компоненты внутри Сервера заказов (Уровень 3)
                order_ctrl = component "OrderController" "REST-эндпоинты для заказов" "Spring MVC"
                order_svc = component "OrderService" "Создание и управление заказами" "Kotlin"
                price_svc = component "PricingService" "Расчёт стоимости по тарифу" "Kotlin"
                repo = component "OrderRepository" "Доступ к данным заказов" "Spring Data JPA"
                event_pub = component "EventPublisher" "Публикация доменных событий" "Kotlin"
            }
            
            db = container "База данных" "Хранение пользователей и поездок" "PostgreSQL" "Database"
            bus = container "Очередь событий" "Асинхронная обработка" "RabbitMQ" "Queue"
            worker = container "Сервис подбора" "Поиск ближайшего водителя по событию" "Kotlin"
        }

        // 4. Связи между людьми и системами
        client -> mobile_app "Использует" "HTTPS"
        driver -> driver_app "Использует" "HTTPS"
        
        // Связи мобильных приложений с системой
        mobile_app -> api_gateway "Отправляет запросы" "JSON/HTTPS"
        driver_app -> api_gateway "Отправляет запросы" "JSON/HTTPS"
        api_gateway -> order_ctrl "Направляет запрос" "HTTP"

        // Связи внутри бэкенда (компоненты)
        order_ctrl -> order_svc "Вызывает методы"
        order_svc -> price_svc "Рассчитывает цену"
        order_svc -> repo "Сохраняет заказ"
        order_svc -> event_pub "Публикует события"

        // Связи с инфраструктурой
        repo -> db "Читает и пишет" "JDBC"
        event_pub -> bus "Отправляет события" "AMQP"
        bus -> worker "Доставляет события" "AMQP"
        worker -> db "Обновляет статусы" "JDBC"

        // Связи с внешними системами
        backend -> payment_gw "Проводит платежи" "HTTPS"
        backend -> maps_api "Запрашивает геоданные" "HTTPS"
        worker -> sms_gw "Отправляет СМС" "HTTPS"
    }

    // 5. Генерация видов (диаграмм)
    views {
        // Диаграмма Контекста (Уровень 1)
        systemContext taxi_system "Context" {
            include *
            autolayout lr
        }
        
        // Диаграмма Контейнеров (Уровень 2)
        container taxi_system "Containers" {
            include *
            autolayout lr
        }
        
        // Диаграмма Компонентов (Уровень 3)
        component backend "Components" {
            include *
            autolayout lr
        }
        
        theme default
    }
}