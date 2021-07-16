import psycopg2
import random

conf = {'host': 'localhost', 'database': 'election_db_project', 'user': 'saee', 'password': 'god'}
random.seed(10)


def create_election():
    connection = psycopg2.connect(**conf)
    cursor = connection.cursor()

    cursor.execute(f"insert into election values ('chair', 1400, 35, 0, 70);")

    connection.commit()
    print('done')
    cursor.close()
    connection.close()


if __name__ == '__main__':
    # create_election()
    print('mock data has been created.')
