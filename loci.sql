CREATE TABLE antismash.loci (
    id	serial NOT NULL,
    start_pos	int4,
    end_pos	int4,
    strand	char(1),
    sequence	int4,
    CONSTRAINT loci_pkey PRIMARY KEY (id),
    CONSTRAINT loci_sequence_fkey FOREIGN KEY (sequence) REFERENCES antismash.dna_sequences (id)
);