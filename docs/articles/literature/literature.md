# Literature

**This bibliography contains all peer-reviewed publications and
PhD-dissertations linked to WATLAS**

The `.bib` file containing the full bibliography in `BibTeX` can be
downloaded
[here](https://github.com/allertbijleveld/tools4watlas/blob/master/vignettes/literature/literature.bib).

## Introduction

Tracking animal movement is crucial for understanding interactions with
changing environments and predicting the effects of anthropogenic
activities, particularly in ecologically significant areas like the
Wadden Sea. The WATLAS system (i.e. the Wadden Sea deployment of ATLAS -
Advanced Tracking and Localisation of Animals in real life Systems)
enables high-resolution monitoring of small bird movements, offering
insights into space use, individual variation, and social networks,
thereby supporting research and conservation efforts in the region. A
detailed description of WATLAS can be found in **Bijleveld et al.
([2022](#ref-bijleveld2022))**.

In **Nathan et al. ([2022](#ref-nathan2022))** we discuss how big-data
approaches, such as high-throughput tracking with WATLAS, can lead to an
increased understanding of the ecology of animal movement. Particularly
that advances in high-throughput wildlife tracking systems now allow
more thorough investigation of variation among individuals and species
across space and time, the nature of biological interactions, and
behavioral responses to the environment.

## Prologue to WATLAS

ATLAS builds on and is inspired by ‘Time Of Arrival’-tracking developed
by **MacCurdy et al. ([2009](#ref-maccurdy2009))** and described in
**MacCurdy et al. ([2018](#ref-maccurdy2019))**, which includes a pilot
study in the Wadden Sea as a ‘proof of concept’. The method was further
developed for its application to Red Knots in the Wadden Sea
**([Bijleveld, 2015](#ref-bijleveldthesis))**. In **MacCurdy et al.
([2015](#ref-maccurdyinthesis))**, we reviewed tracking technologies and
show that many of the tools are inapplicable to most species due to
mass, cost and energy constraints. We presented ‘Time Of
Arrival’-tracking and argue that this can be broadly applied to species
that were previously too small for automated tracking systems at low
costs, thus offering researchers unprecedented amounts of data allowing
for novel insights.

After these initial tests in 2008-2009, this pre-WATLAS ‘Time Of
Arrival’-tracking system was deployed in the Wadden Sea with 15
receivers studying red knot habitat use. After much trial and error, we
could show in **Bijleveld et al. ([2016](#ref-bijleveld2016))** how red
knots selected habitat to maximise their energy intake rates. They did,
however, not select areas with the highest density of prey but trade-off
prey quantity and quality. Moreover, individuals differed in how they
leaned towards quantity or quality of prey in selecting mudflat habitat.

After the success in the Wadden Sea, we also deployed TOA-tracking in
Mauritania. Consistent with previous empirical studies, patch residence
times in the field were positively correlated with gizzard mass. A
manipulation of gizzard mass revealed that Red Knots released with
experimentally reduced gizzard masses did not decrease patch residence
times accordingly. These findings suggest that diet preferences can
cause the observed among-individual variation in gizzard mass and patch
residence times **([Oudman et al., 2016](#ref-oudman2016))**.

Having deployed the same tracking and resouce sampling methods in
Mauritania and the Wadden Sea allowed a comparisson within species
**([Oudman et al., 2018](#ref-oudman2018))**. Compared to Banc d’Arguin,
resource patches in the Wadden Sea were larger and the maximum local
resource abundance was higher. However, because of constraints set by
digestive capacity, the average potential intake rates by red knots were
similar at the two study sites. Space-use patterns differed as predicted
from these differences in resource landscapes. Foraging red knots in the
Wadden Sea roamed the mudflats in large aggregations without site
fidelity (i.e. grouping nomads), whereas in Banc d’Arguin they acted
more individually with strong site-fidelity (i.e. solitary residents).

For a broader review on circadian rhythms, we re-analysed the high
resolution tracking data from Red Knots in Mauritanie. We revealed
individual differences in tidal and circadian foraging rhythms and
highlight potential fruitful avenues for further studies **([Bulla et
al., 2017](#ref-bulla2017))**.

## WATLAS

After an intitial development starting in 2016, we first deployed WATLAS
as a pilot study near Griend with 5 receivers in 2017. After its succes,
we deployed 15 recievers in 2018 and scaled-up to almost 30 receivers in
2019 covering a large part of the Western Dutch Wadden Sea. From 2025
onwards, WATLAS will be further developed to cover the entire Dutch
Wadden Sea.

### Validation

Validation of methods is crucial for understanding the strengths and
limitations. In **Beardsworth et al. ([2022](#ref-beardsworth2022))** we
tested the accuracy and precision of WATLAS using concurrent GPS
measurements as a reference. The median accuracy of WATLAS was 4 m
compared with GPS localizations. Localizations that were collected by
more receiver stations were more accurate. The three-receiver
localizations provided an accuracy of 10 m, which increased to 3 m with
seven receivers contributing to the localization. Applying
Filter-Smoothing on the data further increased the accuracy to 6 m for
three-receiver localizations and to 2 m for seven-receiver
localizations.

### Methods

A pipeline with coding examples for cleaning (e.g. Filter-Smoothing)
high-throughput tracking data with `atlastools` is presented in **Gupte
et al. ([2022](#ref-gupte2022))**. Note that `tools4watlas` is developed
from `atlastools`.

In **Toledo et al. ([2022](#ref-toledo2022))** we describe our tags and
particulary the design of these versatile, widely-applicable, and
field-proven ‘Vildehaye’ tags for wildlife sensing and radio tracking.
Also, we discuss longevity of tags and show that WATLAS tags with a
CR2032 battery transmitting at 6 s can last 226 days.

### Ecology

#### Migration, relocation and departure decisions

Using WATLAS to record the timing of migration, we showed that red knots
that had ad libitum food in captivity departed earlier on spring
migration from the Wadden Sea than birds with restricted food access.
Becasue Red Knots adjust their mass gain and moult rates to local
foraging conditions, this study suggests that improved food conditions
at staging sites, like the Wadden Sea, could enable earlier departures
and help migratory birds better track advancing spring under climate
warming ([Lameris et al., 2025](#ref-lameris2025)).

In **Gobbens et al. ([2024](#ref-gobbens2024))**, we studied the
environmental conditions that red knots selected for relocation flights
across the North Sea to the United Kingdom. Approximately 37% of tagged
red knots departed yearly and on average did so a few hours after
sunset, 4h before high tide, with tailwinds, and little cloud cover.

#### Habitat use and resource selection

We are interested whether shorebird select mudflat habitat where they
can maximise their energy intake rates, that is where food densities are
high. In **Penning et al. (in prep)**, we show that Sanderling select
intertidal mudflats that contain the highest densities of Brown Shrimp.
Becasue of tag weight constraints and Sanderling being so small, this is
the first time ever that Sanderling have been tracked at such high
spatiotemporal resolution.

In **Danielson-Owczynsky et al. (in prep)**, we show that Bar-tailed
Godwits select areas where they their preferred prey are most abundant.
For long-billed females these were areas with high densities of Lugworms
and Ragworms, which live deeper in the sediment. Males with shorter
bills, however, almost exclusively consumed and selected areas with high
densities of Mud Shrimp that live more superficially on the mudflats.
The latter, that fuelling Bar-tailed godwits forage primarily on Mud
Shrimp, has not been documented before.

#### Individual variation

In **Ersoy et al. ([2022](#ref-ersoy2022))** we showed that foraging
tactics and diet are associated with the personality trait exploration,
independent of morphological differences. WATLAS was used to locate
tagged individuals on mudflats for detailed behavioural observations.

Following this result, in **Ersoy et al. ([2024](#ref-ersoy2024))**, we
studied the development of consistent exploration behaviour and found
that juvenile red knots had a more diverse diet than adults and had less
consistent personalites. We discuss a pathway how early foraging
experiences could shape development of exploratory personalities. WATLAS
was used to show how juvenile red knots differed in habitat use, which
is presented in the appendix.

#### Climate change

With the climiate crisis, extreme wind speeds are predicted to occur
more frequently and pose a threat to shorebirds. In **Keuning et al. (in
prep)**, we studied how strong winds affect the availability of
intertidal foraging habitat through increased water levels (‘wind
setup’) and the behaviour of Red Knots. With high wind speeds from the
West, up to 50% of mudflats stayed submerged and the availability of
prey was reduced by 44%. Moreover, with strong headwinds, birds roosted
closer by. These wind-driven effects are likely to increase energetic
costs while reducing opportunities for food intake, thereby reshaping
energy balances.

## PhD-dissertations

The pre-WATLAS insights were also published within the dissertations of
Thomas Oudman **([Oudman, 2017](#ref-oudmanthesis))** and Allert
Bijleveld **([Bijleveld, 2015](#ref-bijleveldthesis))**. so far, WATLAS
has been part of the dissertations of Eva Kok **([Kok,
2020](#ref-kokthesis))**, Selin Erosy **([Ersoy,
2022](#ref-ersoythesis))**, and Emma Penning **([Penning,
2023](#ref-penningthesis))**.

## Bibliography

Beardsworth, C. E., Gobbens, E., Maarseveen, F. van, Denissen, B.,
Dekinga, A., Nathan, R., Toledo, S., & Bijleveld, A. I. (2022).
**Validating ATLAS: A regional-scale high-throughput tracking system**.
*Methods in Ecology and Evolution*, *13*(9), 1990–2004.
<https://doi.org/10.1111/2041-210X.13913>

Bijleveld, A. I. (2015). ***Untying the knot: Mechanistically
understanding the interactions between social foragers and their prey***
\[Thesis\].
<https://hdl.handle.net/11370/cba07229-1ddc-476d-8d93-e9574cbe6685>

Bijleveld, A. I., Maarseveen, F. van, Denissen, B., Dekinga, A.,
Penning, E., Ersoy, S., Gupte, P. R., Monte, L. de, Horn, J. ten, Bom,
R. A., Toledo, S., Nathan, R., & Beardsworth, C. E. (2022). **WATLAS:
High-throughput and real-time tracking of many small birds in the dutch
wadden sea**. *Animal Biotelemetry*, *10*(1), 36.
<https://doi.org/10.1186/s40317-022-00307-w>

Bijleveld, A. I., MacCurdy, R. B., Chan, Y.-C., Penning, E., Gabrielson,
R. M., Cluderay, J., Spaulding, E. L., Dekinga, A., Holthuijsen, S.,
Horn, J. ten, Brugge, M., Gils, J. A. van, Winkler, D. W., & Piersma, T.
(2016). **Understanding spatial distributions: Negative
density-dependence in prey causes predators to trade-off prey quantity
with quality**. *Proceedings of the Royal Society B: Biological
Sciences*, *283*(1828), 20151557.
<https://doi.org/10.1098/rspb.2015.1557>

Bulla, M., Oudman, T., Bijleveld, A. I., Piersma, T., & Kyriacou, C. P.
(2017). **Marine biorhythms: Bridging chronobiology and ecology**.
*Philosophical Transactions of the Royal Society B: Biological
Sciences*, *372*(1734). <https://doi.org/10.1098/rstb.2016.0253>

Ersoy, S. (2022). ***Exploration in red knots: The role of personality
in the expression of individual behaviour across contexts*** \[Thesis\].
<https://doi.org/10.33612/diss.248380062>

Ersoy, S., Beardsworth, C. E., Dekinga, A., Meer, M. T. J. van der,
Piersma, T., Groothuis, T. G. G., & Bijleveld, A. I. (2022).
**Exploration speed in captivity predicts foraging tactics and diet in
free-living red knots**. *Journal of Animal Ecology*, *91*(2), 356–366.
<https://doi.org/10.1111/1365-2656.13632>

Ersoy, S., Beardsworth, C. E., Duran, E., van der Meer, M. T. J.,
Piersma, T., Groothuis, T. G. G., & Bijleveld, A. I. (2024). **Pathway
for personality development: Juvenile red knots vary more in diet and
exploratory behaviour than adults**. *Animal Behaviour*, *208*, 31–40.
<https://doi.org/10.1016/j.anbehav.2023.11.018>

Gobbens, E., Beardsworth, C. E., Dekinga, A., Horn, J. ten, Toledo, S.,
Nathan, R., & Bijleveld, A. I. (2024). **Environmental factors
influencing red knot (calidris canutus islandica) departure times of
relocation flights within the non-breeding period**. *Ecology and
Evolution*, *14*(3), e10954. <https://doi.org/10.1002/ece3.10954>

Gupte, P. R., Beardsworth, C. E., Spiegel, O., Lourie, E., Toledo, S.,
Nathan, R., & Bijleveld, A. I. (2022). **A guide to pre-processing
high-throughput animal tracking data**. *Journal of Animal Ecology*,
*91*(2), 287–307. <https://doi.org/10.1111/1365-2656.13610>

Kok, E. M. A. (2020). ***Why knot? Exploration of variation in
long-distance migration*** \[Thesis\].
<https://doi.org/10.33612/diss.132591058>

Lameris, T. K., Bijleveld, A. I., Bom, R. A., Karagicheva, J., Kressin,
H., Kok, E. M. A., Lagerveld, S., Monte, L. G. G. de, Helm, B., &
Piersma, T. (2025). **Experimentally increased food availability allows
for earlier departure in a long-distance migratory shorebird**.
*Functional Ecology*, *39*, 3434–3445.
<https://doi.org/10.1111/1365-2435.70183>

MacCurdy, R. B., Bijleveld, A. I., Gabrielson, R. M., & Cortopassi, K.
A. (2018). **Automated wildlife radio tracking**. In *Handbook of
position location* (pp. 1219–1261). John Wiley & Sons, Ltd.
<https://doi.org/10.1002/9781119434610.ch33>

MacCurdy, R. B., Bijleveld, A. I., Gabrielson, R., Cluderay, J.,
Spaulding, E., Oudman, T., Gils, J. A. van, Dekinga, A., Piersma, T., &
Winkler, D. W. (2015). **Automatic, intensive wildlife radiotracking**
\[Book Section\]. In A. I. Bijleveld (Ed.), *Untying the knot* (pp.
41–52). <https://research.rug.nl/files/20140463/Chapter_3_.pdf>

MacCurdy, R. B., Gabrielson, R. M., Spaulding, E., Purgue, A.,
Cortopassi, K. A., & Fristrup, K. M. (2009). **Automatic animal tracking
using matched filters and time difference of arrival**. *Journal of
Communications*, *4*, 487–495.
<https://doi.org/doi:10.4304/jcm.4.7.487-495>

Nathan, R., Monk, C. T., Arlinghaus, R., Adam, T., Alós, J., Assaf, M.,
Baktoft, H., Beardsworth, C. E., Bertram, M. G., Bijleveld, A. I.,
Brodin, T., Brooks, J. L., Campos-Candela, A., Cooke, S. J., Gjelland,
K. Ø., Gupte, P. R., Harel, R., Hellström, G., Jeltsch, F., … Jarić, I.
(2022). **Big-data approaches lead to an increased understanding of the
ecology of animal movement**. *Science*, *375*(6582), eabg1780.
<https://doi.org/10.1126/science.abg1780>

Oudman, T. (2017). ***Red knot habits: An optimal foraging perspective
on tidal life at banc d’arguin*** \[Thesis\].
<https://hdl.handle.net/11370/4ea6a0b1-5ad0-45e0-9deb-a34899c0a8fb>

Oudman, T., Bijleveld, A. I., Kavelaars, M. M., Dekinga, A., Cluderay,
J., Piersma, T., & Gils, J. A. van. (2016). **Diet preferences as the
cause of individual differences rather than the consequence**. *Journal
of Animal Ecology*, *85*(5), 1378–1388.
<https://doi.org/10.1111/1365-2656.12549>

Oudman, T., Piersma, T., Ahmedou Salem, M. V., Feis, M. E., Dekinga, A.,
Holthuijsen, S., Horn, J. ten, Gils, J. A. van, & Bijleveld, A. I.
(2018). **Resource landscapes explain contrasting patterns of
aggregation and site fidelity by red knots at two wintering sites**.
*Movement Ecology*, *6*(1), 24.
<https://doi.org/10.1186/s40462-018-0142-4>

Penning, E. (2023). ***Sanderlinks*** \[Thesis\].
<https://doi.org/10.33612/diss.830020613>

Toledo, S., Mendel, S., Levi, A., Vortman, Y., Ullmann, W., Scherer,
L.-R., Pufelski, J., Maarseveen, F. van, Denissen, B., Bijleveld, A. I.,
Orchan, Y., Bartan, Y., Margalit, S., Talmon, I., & Nathan, R. (2022).
**Vildehaye: A family of versatile, widely-applicable, and field-proven
lightweight wildlife tracking and sensing tags**. *2022 21st ACM/IEEE
International Conference on Information Processing in Sensor Networks
(IPSN)*, 1–14. <https://doi.org/10.1109/IPSN54338.2022.00008>
