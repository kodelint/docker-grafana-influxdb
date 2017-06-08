import pika
import json
import datetime
import logging
from influxdb import InfluxDBClient
import platform

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

handler = logging.FileHandler('/var/log/consumer.log')
handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)

logger.addHandler(handler)
logger.info("Starting zeus events subscriber with python version {0}".format(platform.python_version()))


connection = pika.BlockingConnection(pika.ConnectionParameters(host='dev.zeus.fds.com'))
channel = connection.channel()

channel.exchange_declare(exchange='zeusevents', exchange_type='fanout')

result = channel.queue_declare(exclusive=True)
queue_name = result.method.queue

channel.queue_bind(exchange='zeusevents', queue=queue_name)


def jsontoinflux(body):
    data = json.loads(body)
    logger.info('Event notification from zeus %s', data)

    if not data:
        logger.warning('No event data found in RabbitMQ [%s]', host)
    else:
        env = data['name']
        project = data['project']
        created = data['created']
        state = data['state']
        deleted = data['deleted']
        owner = data['owner']
        source_blueprint_name = data['source_blueprint_name']

    if deleted:
        status = "deleted"
    else:
        status = "created"

    json_body = [
        {
            "measurement": "events",
            "tags": {
                "Environment Name": env,
                "Project": project,
                "Created": created,
                "Owner": owner,
                "Deleted": deleted,
                "Blueprint Name": source_blueprint_name
            },
            "fields": {
                "status": status
            }
        }
    ]
    logger.info('Pushing zeus event to influxdb %s', json_body)
    client = InfluxDBClient(host='localhost', port=8086, database='zeus_events', username='dashboard', password='supersecretpw')
    print('Writing message to influxDB %s', json_body)
    client.write_points(json_body)


def callback(ch, method, properties, body):
    jsontoinflux(body)

channel.basic_consume(callback, queue_name, no_ack=True)
channel.start_consuming()