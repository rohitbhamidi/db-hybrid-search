-- set the query vector
set @query_vec = (select v from vecs where id = 2251799813701581);

-- building the hybrid search
with fts as(
    select id, paragraph, match (paragraph) against ('AAA games') as score
    from vecs
    where match (paragraph) against ('AAA games')
    order by score desc
    limit 200
),
vs as (
    select id, paragraph, v <*> @v_mario as score
    from vecs
    order by score use index (auto) desc
    limit 200
)
select vs.id,
    vs.paragraph,
    .3 * ifnull(fts.score, 0) + .7 * vs.score as hybrid_score,
    vs.score as vec_score,
    ifnull(fts.score, 0) as ft_score
from fts full outer join vs
    on fts.id = vs.id
order by hybrid_score desc
limit 5;