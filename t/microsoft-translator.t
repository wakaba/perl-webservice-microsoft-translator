use strict;
BEGIN {
    my $file_name = __FILE__; $file_name =~ s{[^/]+$}{}; $file_name ||= '.';
    $file_name .= '/../config/perl/libs.txt';
    open my $file, '<', $file_name or die "$0: $file_name: $!";
    unshift @INC, split /:/, scalar <$file>;
}
use warnings;
use Test::X1;
use Test::More;
use HTTest::Mock;
use WebService::Microsoft::Translator;
use HTTest::Mock::Microsoft::Translator;
use Encode;

my $app_id = "THISISDAMMYAPPID";
my $mock_translated = decode('utf-8', 'This is the HTTP responses with Mock. モックからのHTTP
レスポンスです.');

test {
    my $c = shift;
    my $translator = WebService::Microsoft::Translator->new(
        app_id  => $app_id,
    );

    is $translator->{app_id}, $app_id;
    done $c;
} n => 1;

test {
    my $c = shift;
    my $text = '"_test"';
    my $translator = WebService::Microsoft::Translator->new(
        app_id  => $app_id,
    );
    is $translator->encode_system_string($text), '_. ' . $text;
    is $translator->decode_system_string($text), 'test';
    done $c;
} n => 2;

test {
    my $c = shift;
    my $translator = WebService::Microsoft::Translator->new(
        app_id  => $app_id,
    );
    my $translated = $translator->translate (
        from    => 'ja',
        to      => 'en',
        text    => 'テストテスト',
    );

    is $translated, $mock_translated;
    done $c;
} n => 1;

run_tests;
