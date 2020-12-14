Logging pipeline


# Масштабування
Механізм масштабування для компонента logging заснований на масштабуванні сховища логів - бази даних Elasticsearch. Вся конфігурація масштабування кластера Elasticsearch реалізована з урахуванням використання оператора Openshift Cluster Logging.  
Масштабування кластера Elasticsearch досягається за рахунок горизонтального масштабування, тобто додаванням нових нод в кластер Elasticsearch.  
Базові параметри конфігурації масштабування знаходяться у файлi /deploy-templates/values.yaml, в розділі "scaling". Розширені параметри конфігурації масштабування кластера Elasticsearch знаходяться у файлі /deploy-templates/logging-instance/templates/050-clo-instance.yaml, тобто CR ClusterLogging інстансу.

## Вимоги
У базовій конфігурації, кожна нода кластера Elasticsearch вимагає 16Gb ресурсів пам'яті. Більш детально параметр конфігурації ресурсів (spec.logStore.elasticsearch.resources) нод кластера Elasticsearch описаний нижче.

## Базові параметри конфігурації масштабування кластера Elasticsearch
Файл /deploy-templates/values.yaml
- scaling_es_node_count - кількість нод кластера Elasticsearch. Мінімально рекомендоване значення - 3.
- scaling_es_node_storage_size - розмір сховища (volume) для ноди кластера Elasticsearch. Необхідно вибрати потрібне значення.

## Розширені параметри конфігурації масштабування кластера Elasticsearch
Файл /deploy-templates/logging-instance/templates/050-clo-instance.yaml
- "spec.logStore.elasticsearch.redundancyPolicy" - політики резервування. Оптимальне рекомендоване значення - "MultipleRedundancy". Для максимального рівня відмовостійкості - необхідно використовувати FullRedundancy режим.
- "spec.logStore.elasticsearch.storageClassName: тип сховища (storage class). В разі використання AWS може бути "gp2".
- "spec.managementState" - параметр відповідає за управління конфігурацією інстансу логгінгу оператором Openshift Cluster Logging. Значення має бути "Managed", тобто управління конфігурацією здійснюється оператором.
- "spec.logStore.elasticsearch.resources" - необов'язковий параметр, що відповідає за конфігурацію ресурсів виділяються для ноди кластера Elasticsearch. Стандартні значення виділяються для ноди кластера Elasticsearch - 16Gb пам'яті. Більш детальна інформація доступна на https://docs.openshift.com/container-platform/4.4/logging/config/cluster-logging-elasticsearch.html#cluster-logging-elasticsearch-limits_cluster-logging-elasticsearch

## Обмеження
1. В рамках використання Openshift Cluster Logging, конфігурація масштабування (scale-up, scale-down) кластера Elasticsearch можлива тільки для кількості нод від 1 до 3 (включно). Якщо встановити значення "nodeCount" більше 3-х, оператор перестає реагувати на зміну даного параметра конфігурації.
2. В рамках використання Openshift Cluster Logging, змінити розмір сховища (volume) для ноди кластера Elasticsearch можливо тільки для нового інстансу ноди Elasticsearch, для поточних нод змінити розмір сховища (volume) немає можливості.
