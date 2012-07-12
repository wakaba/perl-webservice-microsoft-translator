use strict;
BEGIN {
    my $file_name = __FILE__; $file_name =~ s{[^/]+$}{}; $file_name ||= '.';
    $file_name .= '/../config/perl/libs.txt';
    open my $file, '<', $file_name or die "$0: $file_name: $!";
    unshift @INC, split /:/, scalar <$file>;
}
use warnings;
use Path::Class;
use WebService::Microsoft::Translator;
use Encode;

my $app_id = shift;
my $from_lang = shift;
my $to_lang = shift;
my $text = decode 'utf-8', shift;

my $translator = WebService::Microsoft::Translator->new(
    app_id  => $app_id,
);
my $translated = $translator->translate(
    from    => $from_lang,
    to      => $to_lang,
    text    => $text,
);

print $translated, "\n";
