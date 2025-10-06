#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Regru::API;
use Data::Dumper;

# Конфигурация подключения к API
my $USERNAME = 'your_username';      # Ваш логин в Reg.ru
my $PASSWORD = 'your_password';      # Ваш пароль от личного кабинета

# Идентификатор вашего VPS сервера
# Можно использовать service_id (рекомендуется) или dname
my $SERVICE_ID = 'your_service_id';  # Числовой ID услуги VPS
# или
my $DNAME = 'your_vps_name';         # Имя VPS сервера

# Создание объекта API
my $api = Regru::API->new(
    username => $USERNAME,
    password => $PASSWORD,
    # debug    => 1,  # Раскомментируйте для отладки
);

# Проверка подключения к API
print "Проверка подключения к API Reg.ru...\n";
my $nop_result = $api->nop;

if ($nop_result->is_success) {
    print "✓ Подключение к API успешно установлено\n\n";
} else {
    die "✗ Ошибка подключения к API: " . $nop_result->error_text . "\n";
}

# Включение виртуального сервера (функция service/resume)
print "Попытка включения виртуального сервера...\n";

my $params = {};

# Выбор метода идентификации услуги
if ($SERVICE_ID && $SERVICE_ID ne 'your_service_id') {
    # Идентификация по service_id (рекомендуется)
    $params->{service_id} = $SERVICE_ID;
    print "Использование service_id: $SERVICE_ID\n";
} elsif ($DNAME && $DNAME ne 'your_vps_name') {
    # Идентификация по dname
    $params->{dname} = $DNAME;
    print "Использование dname: $DNAME\n";
} else {
    die "✗ Ошибка: необходимо указать SERVICE_ID или DNAME\n";
}

# Вызов функции service/resume для включения сервера
my $result = $api->service->resume(%$params);

# Обработка результата
if ($result->is_success) {
    print "✓ Виртуальный сервер успешно включен!\n";
    print "\nОтвет от API:\n";
    print Dumper($result->answer);
} else {
    print "✗ Ошибка при включении сервера\n";
    print "Код ошибки: " . $result->error_code . "\n" if $result->error_code;
    print "Текст ошибки: " . $result->error_text . "\n" if $result->error_text;
    
    # Дополнительная информация об ошибках
    if ($result->error_code eq 'SERVICE_NOT_SUSPENDED') {
        print "\nВнимание: Сервер уже включен (не приостановлен)\n";
    } elsif ($result->error_code eq 'SERVICE_EXPIRED') {
        print "\nВнимание: Срок действия услуги истек\n";
    }
}

print "\nГотово.\n";

__END__

=head1 NAME

power_on_vps.pl - Скрипт для включения виртуального сервера через API Reg.ru

=head1 SYNOPSIS

    perl power_on_vps.pl

=head1 DESCRIPTION

Этот скрипт использует библиотеку Regru::API для включения (возобновления)
виртуального сервера в личном кабинете cloud.reg.ru через функцию API
service/resume.

=head1 НАСТРОЙКА

Перед использованием необходимо указать:

=over 4

=item * B<USERNAME> - ваш логин в Reg.ru

=item * B<PASSWORD> - ваш пароль от личного кабинета

=item * B<SERVICE_ID> - числовой идентификатор вашего VPS сервера (рекомендуется)

=back

Альтернативно можно использовать параметр DNAME (имя VPS).

=head1 ТРЕБОВАНИЯ

Необходимо установить модуль Regru::API:

    cpan Regru::API

или

    cpanm Regru::API

=head1 ФУНКЦИИ API

Скрипт использует следующие функции Reg.ru API v2:

=over 4

=item * B<service/nop> - проверка доступности API

=item * B<service/resume> - возобновление (включение) услуги

=back

=head1 ИДЕНТИФИКАЦИЯ УСЛУГИ

Возможны два способа идентификации VPS сервера:

=over 4

=item 1. По service_id (рекомендуется) - числовой идентификатор услуги

=item 2. По dname - имя VPS сервера

=back

Получить service_id можно через функцию service/get_list или в личном
кабинете Reg.ru.

=head1 ВОЗМОЖНЫЕ ОШИБКИ

=over 4

=item * B<SERVICE_NOT_SUSPENDED> - услуга не приостановлена (уже включена)

=item * B<SERVICE_EXPIRED> - срок действия услуги истек

=back

=head1 ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ

Узнать service_id вашего VPS можно так:

    use Regru::API;
    
    my $api = Regru::API->new(
        username => 'your_username',
        password => 'your_password',
    );
    
    my $services = $api->service->get_list;
    print Dumper($services->answer);

=head1 АВТОР

Создано на основе документации Reg.ru API v2

=head1 ССЫЛКИ

=over 4

=item * L<Документация Reg.ru API|https://www.reg.ru/support/api-dokumentatsiya>

=item * L<Библиотека Regru::API на CPAN|https://metacpan.org/pod/Regru::API>

=item * L<GitHub Regru::API|https://github.com/regru/regru-api-perl>

=back

=cut
