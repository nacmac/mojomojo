#!/usr/bin/perl -w
use Test::More tests => 32;
use MojoMojo::Formatter::Wiki;
use lib 't/lib';
use FakeCatalystObject;

my ($content,$exist,$new);
# this fake object returns different path_pages based on whether a wiki link containing the text "existing"
my $fake_c = FakeCatalystObject->new;

TODO: {
    local $TODO = 'Make this test work.  It fails because of the number, 2. The $content does not get formatted at all so it\'s bypassing format_content.';
    $content = '[[existing|MojoMojo 2]]';
    MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
    is($content, '<a class="existingWikiWord" href="/existing">MojoMojo 2</a>', 'number at the end of the link text');
}


$content = '\[[WikiWord]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '[[WikiWord]]', 'escaping opening [[');

$content = '/[[wikiword]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '/[[wikiword]]', 'escaping URL path');

$content = "WikiWord";
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'WikiWord', 'no CamelCase for new WikiWords');

$content = "ExistingWord";
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'ExistingWord', 'no CamelCase for existing WikiWords');

$content = 'This is an [[explicit_link|explicit wiki link]].';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'This is an <span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/explicit_link.edit">explicit wiki link?</a></span>.', 'explicit wiki links');

$content = 'New [[wiki link]]. No <pre lang="">[[wiki link]] hyperlinking in code sections</pre>. Here is an [[Existing_link]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'New <span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/wiki_link.edit">wiki link?</a></span>. No <pre lang="">[[wiki link]] hyperlinking in code sections</pre>. Here is an <a class="existingWikiWord" href="/Existing_link">Existing link</a>', 'no wiki link hyperlinking in code sections');

$content = 'This is an [[explicit_link|explicit wiki link with (parens) and [square brackets] in the text]].';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'This is an <span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/explicit_link.edit">explicit wiki link with (parens) and [square brackets] in the text?</a></span>.', 'explicit wiki links with parens and square brackets in the text');

$content = 'Implicit link: [[Devil\'s_advocate_(disambiguation)]].';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'Implicit link: <span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/Devil\'s_advocate_(disambiguation).edit">Devil\'s advocate (disambiguation)?</a></span>.', 'implicit link with apostrophe and parens in the path');

$content = 'Implicit link with [[a [square] bracket]].';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'Implicit link with <span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/a_[square]_bracket.edit">a [square] bracket?</a></span>.', 'implicit link with a [square] bracket');

TODO: {
    local $TODO = 'Not exactly a critical issue';
    $content = 'Implicit link: [[Closed_square_bracket_at_the_[end]]].';
    MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
    is($content, 'Implicit link: <span class="newWikiWord">Closed square bracket at the [end]<a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/Closed_square_bracket_at_the_[end].edit">?</a></span>.', 'implicit link with closed square bracket at the end');
}

$content = '[[Say a 100% "NO" to #8]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '<span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/Say_a_100%25_%22NO%22_to_%238.edit">Say a 100% "NO" to #8?</a></span>', 'implicit wikilink with anchor (#) sign');

$content = 'explicit link with anchor [[/existing/link#new_anchor|Anchor within existing page]].';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'explicit link with anchor <a class="existingWikiWord" href="existing/link#new_anchor">Anchor within existing page</a>.', 'explicit link with anchor. path_pages must strip the anchor');

$content = '[[/existing_say_%22NO%22_to_%238|Say "NO" to #8]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '<a class="existingWikiWord" href="existing_say_%22NO%22_to_%238">Say "NO" to #8</a>', 'explicit existing wikilink with already URL-encoded characters');

$content = '[[/new_link_say_%22NO%22_to_%238|Say "NO" to #8]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '<span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="new_link_say_%22NO%22_to_%238.edit">Say "NO" to #8?</a></span>', 'explicit new wikilink with already URL-encoded characters');

$content = '[[/new_link_say_%22NO%22_to_%238]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '<span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="new_link_say_%22NO%22_to_%238.edit">new link say "NO" to #8?</a></span>', 'implicit new wikilink with already URL-encoded characters');

$content = '[[79.1% of Americans believe in miracles]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '<span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/79_1%25_of_Americans_believe_in_miracles.edit">79.1% of Americans believe in miracles?</a></span>', 'periods in links become underscores');

$content = '[[.net as a dev platform]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '<span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/_net_as_a_dev_platform.edit">.net as a dev platform?</a></span>', 'periods at the start of wikilinks become underscores');

$content = 'Check this [[../sibling]] page';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, 'Check this <span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="http://example.com/sibling.edit">sibling?</a></span> page', 'links to siblings via ../');

TODO: {
    local $TODO = 'This fails because the dummy Catalyst object needs to fake a base path deeper than /';
    $content = 'Check this [[../../nephew]] page';
    MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
    is($content, 'Check this <span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="../nephew.edit">nephew?</a></span>', 'links to nephews via ../../');
}

$content = '[[We were soldiers once... and young]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '<span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/We_were_soldiers_once____and_young.edit">We were soldiers once... and young?</a></span>', 'wikilink with ellipsis');

TODO: {
    local $TODO = 'This fails because the inner / is detected as delimiting the page title';
    $content = '[[Are you sure that... /. is a great site?]]';
    MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
    is($content, '<span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="/Are_you_sure_that____/__is_a_great_site%3F.edit">Are you sure that... /. is a great site? ?</a></span>', 'elipsis, space and /');
}

TODO: {
    local $TODO = 'We need ot decide if we allow gratuitous .. links like /root/parent/../parent_sibling';
    $content = 'No walking inside known paths like [[/root/parent/../parent_sibling]]. Use [[/root/parent_sibling]] directly.';
    MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
    is($content, 'No walking inside known paths like <span class="newWikiWord"><a title="Faking localization... Not found. Click to create this page. ...fake complete." href="We_were_soldiers_once____and young.edit">nephew?</a></span>', 'wikilink with ellipsis');
}

$content = '[[existing#Really.3F|Really?]]';  # scenario: user copy/pasted the fragment from the ToC link of the target page
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '<a class="existingWikiWord" href="/existing#Really.3F">Really?</a>', 'wikilink fragment with period due to encoding of character illegal in fragments');

$content = '[[existing#Really?|Really?]]';
MojoMojo::Formatter::Wiki->format_content(\$content, $fake_c, undef);
is($content, '<a class="existingWikiWord" href="/existing#Really.3F">Really?</a>', 'wikilink fragment with character illegal in fragments - fragment-escape it');


# expand_wikilink tests
is('foo bar', MojoMojo::Formatter::Wiki->expand_wikilink('foo_bar'), 'expand wikilinks - underscores');


# find_links() tests

$content = 'There is one [[Existing Word]] in this text';
($exist, $new) = MojoMojo::Formatter::Wiki->find_links(\$content, $fake_c);
is(@$exist, 1);
is(@$new, 0);

$content = 'There is one explicit [[Wiki Word]] in this text';
($exist, $new) = MojoMojo::Formatter::Wiki->find_links(\$content, $fake_c);
is(@$exist, 0);
is(@$new, 1);

$content = '[[Wiki Word]] <pre lang="">Blah HubbaBubba Wikiwiord</pre> blah humbug [[Existing Wiki Word]]';
($exist, $new) = MojoMojo::Formatter::Wiki->find_links(\$content, $fake_c);
is(@$exist, 1);
is(@$new, 1);
