SECTIONS {
	/* Ensure that .text starts at the right address,
	 * and that main.o's code comes first */
	.text 0x80200000: {
		main.o(.text)
		*(.text)
	}
}
