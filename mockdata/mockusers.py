import psycopg2
import random

conf = {'host': 'localhost', 'database': 'election_db_project', 'user': 'saee', 'password': 'god'}
random.seed(10)


def create_users():
    connection = psycopg2.connect(**conf)
    cursor = connection.cursor()
    for i in range(100001, 1000000):
        # cursor.execute(f"create role user{i} with login password 'pass';")
        # cursor.execute(f"grant simpleton to user{i};")
        cursor.execute(f"drop role user{i};")
        if i % 1000 == 0:
            connection.commit()
    connection.commit()
    print('done')
    cursor.close()
    connection.close()


def create_regions():
    connection = psycopg2.connect(**conf)
    cursor = connection.cursor()

    for i in range(3, 33):
        cursor.execute(f"insert into region values ({i}, 0, {i // 4 + 1});")
        for j in range(5):
            cursor.execute(f"insert into branch values ({j}, {i});")

    connection.commit()

    print('done')
    cursor.close()
    connection.close()


def create_persons():
    connection = psycopg2.connect(**conf)
    cursor = connection.cursor()

    for i in range(1, 100000):
        if i == 1234 or i == 12342: continue
        minorities = ["'christian'", "'jewish'", "'zardosht'", "'None'"]
        m = 'Null'
        if 99000 < i <= 100000:
            m = minorities[i % 4]
        cursor.execute(f"insert into person values ({i}, 'user{i}', {80 * random.random() + 18}, 1, {m}, "
                       f"{random.random() * 31 + 1});")
        cursor.execute(f"insert into user_person values ('user{i}', {i})")

    connection.commit()
    print('done')
    cursor.close()
    connection.close()


def create_candidates_and_judges():  # candidate [100, 120), judge [200, 210), candidate rank [30, 40), judge rank = 70
    connection = psycopg2.connect(**conf)
    cursor = connection.cursor()

    for i in range(1, 21):
        cursor.execute(f"insert into candidate values ({i}, {i + 99}, 'hi my name is potatoe and my number is {i}',"
                       f" 'https://documents.nowhere.com/candidate{i}', \'{'left' if i % 2 == 0 else 'right'}\', false);")
        cursor.execute(f"update person set rank = {30 + random.random() * 10} where id = {i + 99};")

    for i in range(1, 11):
        cursor.execute(f"insert into judge values ({i}, {i + 199});")
        cursor.execute(f"update person set rank = 70 where id = {i + 199};")

    connection.commit()
    print('done')
    cursor.close()
    connection.close()


if __name__ == '__main__':
    # create_users()
    # create_regions()
    # create_persons()
    # create_candidates_and_judges()
    print('mock data has been created.')

